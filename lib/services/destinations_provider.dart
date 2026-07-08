import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/destination_model.dart';
import '../models/review_model.dart';
import 'api_service.dart';

class DestinationsProvider extends ChangeNotifier {
  static const String _reviewsKey = 'wisata_bengkalis_reviews';
  static const String _adminLoggedInKey = 'admin_is_logged_in';
  static const String _adminUsernameKey = 'admin_logged_in_username';

  List<Destination> _destinations = [];
  List<Review> _reviews = [];
  bool _isAdminLoggedIn = false;
  String _adminUsername = '';

  List<Destination> get destinations => _destinations;
  List<Review> get reviews => _reviews;
  bool get isAdminLoggedIn => _isAdminLoggedIn;
  String get adminUsername => _adminUsername;

  DestinationsProvider() {
    _init();
  }

  Future<void> _init() async {
  print("========== INIT ==========");

  try {
    await fetchDestinationsFromApi();

    print("TOTAL DESTINASI : ${_destinations.length}");
  } catch (e) {
    print("INIT ERROR : $e");
  }

  await _loadReviews();
  await _loadAdminSession();
}

  // --- DESTINATIONS METHODS (PURE API) ---

  Future<void> fetchDestinationsFromApi() async {
  print("FETCH API");

  final data = await ApiService.getDestinations();

  print(data);

  _destinations = data
      .map((e) => Destination.fromJson(e))
      .toList();

  print("HASIL = ${_destinations.length}");

  notifyListeners();
}

  Future<void> addDestination(Destination destination) async {
    try {
      await ApiService.addDestination(destination);
      await fetchDestinationsFromApi(); // Refresh data dari server
    } catch (e) {
      print('Gagal menambah destinasi ke API: $e');
    }
  }

  Future<void> editDestination(Destination destination) async {
    try {
      await ApiService.updateDestination(destination);
      await fetchDestinationsFromApi(); // Refresh data dari server
    } catch (e) {
      print('Gagal mengubah destinasi di API: $e');
    }
  }

  Future<void> deleteDestination(String id) async {
    try {
      await ApiService.deleteDestination(id);
      
      // Hapus reviews lokal yang terkait dengan destinasi ini
      _reviews.removeWhere((r) => r.destinationId == id);
      await _saveReviewsToPrefs();
      
      await fetchDestinationsFromApi(); // Refresh data dari server
    } catch (e) {
      print('Gagal menghapus destinasi di API: $e');
    }
  }

  Future<void> toggleFeatured(String id) async {
    final index = _destinations.indexWhere((d) => d.id == id);
    if (index != -1) {
      try {
        final updatedDest = _destinations[index].copyWith(
          isFeatured: !_destinations[index].isFeatured,
        );
        // Menggunakan ApiService update untuk mengubah status featured di server
        await ApiService.updateDestination(updatedDest);
        await fetchDestinationsFromApi();
      } catch (e) {
        print('Gagal mengubah status featured di API: $e');
      }
    }
  }

  // --- REVIEWS METHODS (MANTAP DI LOCAL SEMENTARA) ---

  Future<void> _loadReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final String? reviewsJson = prefs.getString(_reviewsKey);

    if (reviewsJson == null) {
      _reviews = _getInitialSampleReviews();
      await _saveReviewsToPrefs();
    } else {
      try {
        final List<dynamic> decoded = jsonDecode(reviewsJson);
        _reviews = decoded
            .map((item) => Review.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _reviews = _getInitialSampleReviews();
      }
    }
    notifyListeners();
  }

  Future<void> _saveReviewsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String reviewsJson = jsonEncode(_reviews.map((r) => r.toJson()).toList());
    await prefs.setString(_reviewsKey, reviewsJson);
  }

  Future<void> deleteReview(String id) async {
    _reviews.removeWhere((r) => r.id == id);
    await _saveReviewsToPrefs();
    notifyListeners();
  }

  Future<void> addReview(Review review) async {
    _reviews.insert(0, review);
    
    // Perhitungan rating rata-rata lokal (opsional, data asli idealnya dihitung oleh Backend Laravel)
    final destReviews = _reviews.where((r) => r.destinationId == review.destinationId).toList();
    if (destReviews.isNotEmpty) {
      double totalRating = 0;
      for (var r in destReviews) {
        totalRating += r.rating;
      }
      final newAverage = double.parse((totalRating / destReviews.length).toStringAsFixed(1));
      
      final destIndex = _destinations.indexWhere((d) => d.id == review.destinationId);
      if (destIndex != -1) {
        final updatedDest = _destinations[destIndex].copyWith(rating: newAverage);
        try {
          await ApiService.updateDestination(updatedDest);
        } catch (e) {
          print('Gagal sinkronisasi rating baru ke API: $e');
        }
      }
    }
    
    await _saveReviewsToPrefs();
    await fetchDestinationsFromApi(); // Refresh untuk memastikan state rating sinkron dengan perubahan lokal
  }

  // --- ADMIN SESSION METHODS ---

  Future<void> _loadAdminSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isAdminLoggedIn = prefs.getBool(_adminLoggedInKey) ?? false;
    _adminUsername = prefs.getString(_adminUsernameKey) ?? '';
    notifyListeners();
  }

  Future<bool> loginAdmin(String username, String password) async {
    if (username.trim() == 'admin' && password == 'adminbengkalis') {
      _isAdminLoggedIn = true;
      _adminUsername = 'Administrator Bengkalis';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_adminLoggedInKey, true);
      await prefs.setString(_adminUsernameKey, _adminUsername);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logoutAdmin() async {
    _isAdminLoggedIn = false;
    _adminUsername = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adminLoggedInKey, false);
    await prefs.remove(_adminUsernameKey);
    notifyListeners();
  }

  // --- DUMMY DATA SEEDER FOR REVIEWS ---

  List<Review> _getInitialSampleReviews() {
    final now = DateTime.now();
    return [
      Review(
        id: 'rev_1',
        destinationId: '1',
        username: 'Rahmat Hidayat',
        rating: 5.0,
        content: 'Pantainya bersih sekali, apalagi pas sore hari pemandangannya keren banget! Sunset di sini tidak ada duanya di Bengkalis.',
        photoUrls: [],
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      Review(
        id: 'rev_2',
        destinationId: '1',
        username: 'Siti Aminah',
        rating: 4.0,
        content: 'Sangat cocok untuk piknik bersama keluarga di hari libur. Banyak warung kuliner tradisional, tapi kebersihan sampah mohon lebih diperhatikan lagi.',
        photoUrls: [],
        timestamp: now.subtract(const Duration(days: 5)),
      ),
      Review(
        id: 'rev_3',
        destinationId: '2',
        username: 'Budi Santoso',
        rating: 4.5,
        content: 'Suasananya sangat tenang dan sejuk karena banyak pohon rimbun. Pasir coklatnya unik dan ombaknya pas untuk bersantai.',
        photoUrls: [],
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      Review(
        id: 'rev_4',
        destinationId: '5',
        username: 'Faisal',
        rating: 5.0,
        content: 'MasyaAllah arsitekturnya indah sekali dengan kombinasi warna kubah hijau-biru toska. Tempat ibadah sangat bersih, AC dingin, dan parkiran luas.',
        photoUrls: [],
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      Review(
        id: 'rev_5',
        destinationId: '6',
        username: 'Dewi Sartika',
        rating: 4.7,
        content: 'Tempat edukasi budaya yang sangat berharga di Bengkalis. Kita bisa melihat replika rumah adat Melayu dan belajar sejarah alat musik serta tariannya.',
        photoUrls: [],
        timestamp: now.subtract(const Duration(days: 6)),
      ),
    ];
  }
}