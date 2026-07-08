import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  static const String _favKey = 'favorite_destination_ids';
  static const String _themeKey = 'is_dark_theme';
  
  List<String> _favoriteIds = [];
  bool _isDarkTheme = false;
  
  // User Profile fields
  String _userName = 'Wisatawan Bengkalis';
  String _userEmail = 'wisatawan@bengkalis.go.id';
  String _userAvatar = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80';
  int _userPoints = 450;
  int _visitedCount = 4;

  List<String> get favoriteIds => _favoriteIds;
  bool get isDarkTheme => _isDarkTheme;
  
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userAvatar => _userAvatar;
  int get userPoints => _userPoints;
  int get visitedCount => _visitedCount;

  FavoritesProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList(_favKey) ?? [];
    _isDarkTheme = prefs.getBool(_themeKey) ?? false;
    _userName = prefs.getString('user_name') ?? 'Wisatawan Bengkalis';
    _userEmail = prefs.getString('user_email') ?? 'wisatawan@bengkalis.go.id';
    _userAvatar = prefs.getString('user_avatar') ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80';
    _userPoints = prefs.getInt('user_points') ?? 450;
    _visitedCount = prefs.getInt('user_visited') ?? 4;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    await prefs.setStringList(_favKey, _favoriteIds);
    notifyListeners();
  }

  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkTheme);
    notifyListeners();
  }

  Future<void> updateUserProfile({required String name, required String email}) async {
    _userName = name;
    _userEmail = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    notifyListeners();
  }

  Future<void> updateUserAvatar(String avatarUrl) async {
    _userAvatar = avatarUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', avatarUrl);
    notifyListeners();
  }

  Future<void> incrementVisited() async {
    _visitedCount++;
    _userPoints += 100; // earn 100 points per visit!
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_visited', _visitedCount);
    await prefs.setInt('user_points', _userPoints);
    notifyListeners();
  }
}
