import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Layanan untuk mengelola autentikasi pengguna menggunakan Laravel API & SharedPreferences lokal.
class AuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _currentUserEmailKey = 'current_user_email';
  static const String _usersPrefix = 'user_reg_';

  /// Mendaftarkan pengguna baru.
  /// Mengembalikan [null] jika pendaftaran berhasil,
  /// atau pesan kesalahan [String] jika gagal.
  Future<String?> register(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/register"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'name': user.name,
          'email': user.email,
          'password': user.password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Simpan data pendaftaran secara lokal juga untuk kompatibilitas
        final prefs = await SharedPreferences.getInstance();
        final userKey = '$_usersPrefix${user.email}';
        final userJson = jsonEncode(user.toJson());
        await prefs.setString(userKey, userJson);
        return null;
      } else if (response.statusCode == 422 || response.statusCode == 400) {
        try {
          final body = jsonDecode(response.body);
          if (body is Map) {
            if (body.containsKey('errors')) {
              final errors = body['errors'];
              if (errors is Map && errors.isNotEmpty) {
                return errors.values.first[0].toString();
              }
            }
            if (body.containsKey('message')) {
              return body['message'].toString();
            }
          }
        } catch (_) {}
        return "Email sudah terdaftar atau data tidak valid.";
      } else {
        return "Gagal mendaftar (Status: ${response.statusCode})";
      }
    } catch (e) {
      print("Register API Error: $e");
      return "Gagal terhubung ke server backend ($e). Pastikan server Laravel aktif di 127.0.0.1:8000.";
    }
  }

  /// Melakukan login pengguna.
  /// Mengembalikan objek [UserModel] jika email dan password cocok,
  /// atau [null] jika gagal login (email salah / password salah).
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final userMap = json['user'];
        final token = json['token'];

        final user = UserModel(
          name: userMap['name'] ?? '',
          email: userMap['email'] ?? '',
          password: password,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_isLoggedInKey, true);
        await prefs.setString(_currentUserEmailKey, email);
        await prefs.setString('api_token', token);
        
        // Simpan data pendaftaran secara lokal juga jika belum ada
        final userKey = '$_usersPrefix$email';
        if (!prefs.containsKey(userKey)) {
          await prefs.setString(userKey, jsonEncode(user.toJson()));
        }

        // Sinkronkan nama dan email ke kunci default agar terbaca oleh provider profil
        await prefs.setString('user_name', user.name);
        await prefs.setString('user_email', user.email);
        return user;
      }
    } catch (e) {
      print("Login API Error: $e");
    }
    return null;
  }

  /// Melakukan logout pengguna.
  /// Menghapus sesi aktif dan mengatur ulang nama profil default.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_currentUserEmailKey);
    
    // Kembalikan nama dan email default
    await prefs.setString('user_name', 'Wisatawan Bengkalis');
    await prefs.setString('user_email', 'wisatawan@bengkalis.go.id');
  }

  /// Memeriksa apakah pengguna saat ini dalam status masuk (login).
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Mendapatkan data pengguna yang sedang aktif/login saat ini.
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_currentUserEmailKey);
    if (email == null) return null;

    final userKey = '$_usersPrefix$email';
    final userJson = prefs.getString(userKey);
    if (userJson == null) return null;

    return UserModel.fromJson(jsonDecode(userJson));
  }

  /// Mengganti email pengguna aktif secara lokal dan mencoba memanggil API.
  Future<String?> changeEmail(String currentEmail, String newEmail, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Verifikasi kata sandi terlebih dahulu
      final userKey = '$_usersPrefix$currentEmail';
      final userJson = prefs.getString(userKey);
      if (userJson == null) {
        return "Pengguna tidak ditemukan.";
      }
      
      final userMap = jsonDecode(userJson);
      final storedPassword = userMap['password'] ?? '';
      if (storedPassword != password) {
        return "Kata sandi saat ini tidak cocok.";
      }
      
      // 2. Periksa apakah email baru sudah terdaftar (jika email baru berbeda dari email lama)
      if (currentEmail != newEmail) {
        final newKey = '$_usersPrefix$newEmail';
        if (prefs.containsKey(newKey)) {
          return "Email baru sudah digunakan oleh pengguna lain.";
        }
      }
      
      // 3. Update data pengguna
      userMap['email'] = newEmail;
      final updatedUserJson = jsonEncode(userMap);
      
      // Simpan dengan key baru
      await prefs.setString('$_usersPrefix$newEmail', updatedUserJson);
      
      // Hapus key lama jika email berubah
      if (currentEmail != newEmail) {
        await prefs.remove(userKey);
      }
      
      // Update data sesi aktif
      await prefs.setString(_currentUserEmailKey, newEmail);
      await prefs.setString('user_email', newEmail);
      
      // Opsional: Coba kirim ke API (jika didukung)
      try {
        final token = prefs.getString('api_token');
        if (token != null) {
          await http.put(
            Uri.parse("${ApiService.baseUrl}/user/update-email"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({
              'email': newEmail,
              'password': password,
            }),
          ).timeout(const Duration(seconds: 3));
        }
      } catch (_) {}

      return null; // Sukses
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }

  /// Mengganti kata sandi pengguna aktif secara lokal dan mencoba memanggil API.
  Future<String?> changePassword(String email, String currentPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '$_usersPrefix$email';
      final userJson = prefs.getString(userKey);
      if (userJson == null) {
        return "Pengguna tidak ditemukan.";
      }
      
      final userMap = jsonDecode(userJson);
      final storedPassword = userMap['password'] ?? '';
      if (storedPassword != currentPassword) {
        return "Kata sandi saat ini tidak cocok.";
      }
      
      // Update kata sandi
      userMap['password'] = newPassword;
      await prefs.setString(userKey, jsonEncode(userMap));
      
      // Opsional: Coba kirim ke API (jika didukung)
      try {
        final token = prefs.getString('api_token');
        if (token != null) {
          await http.put(
            Uri.parse("${ApiService.baseUrl}/user/update-password"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode({
              'current_password': currentPassword,
              'new_password': newPassword,
            }),
          ).timeout(const Duration(seconds: 3));
        }
      } catch (_) {}

      return null; // Sukses
    } catch (e) {
      return "Terjadi kesalahan: $e";
    }
  }
}
