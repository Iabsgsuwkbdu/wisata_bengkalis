/// Model untuk menyimpan informasi pengguna yang terdaftar di aplikasi.
class UserModel {
  final String name;
  final String email;
  final String password;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
  });

  /// Mengonversi objek [UserModel] ke dalam format Map (JSON).
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
    };
  }

  /// Membuat objek [UserModel] dari format Map (JSON).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
