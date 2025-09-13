import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  List<String> _bookmarks = []; // ✅ bookmarked event IDs

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  List<String> get bookmarks => _bookmarks;

  /// Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await AuthService.login(email, password);
      _token = data['token'];
      _user = User.fromJson(data['user']);
      _bookmarks = List<String>.from(data['user']['bookmarks'] ?? []); // ✅ load from backend

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ff_token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register
  Future<bool> register(String name, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      await AuthService.register(name, email, password, role);
      return await login(email, password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Fetch Profile
  Future<void> fetchProfile() async {
    if (_token == null) return;
    _user = await AuthService.getProfile(_token!);
    _bookmarks = List<String>.from(_user?.bookmarks ?? []);
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    _user = null;
    _token = null;
    _bookmarks = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ff_token');
    notifyListeners();
  }

  /// ✅ Toggle bookmark
  Future<void> toggleBookmark(String eventId) async {
    if (_token == null) return;
    if (_bookmarks.contains(eventId)) {
      final success = await EventService.removeBookmark(eventId, _token!);
      if (success) _bookmarks.remove(eventId);
    } else {
      final success = await EventService.bookmarkEvent(eventId, _token!);
      if (success) _bookmarks.add(eventId);
    }
    notifyListeners();
  }

  bool isBookmarked(String eventId) {
    return _bookmarks.contains(eventId);
  }
}
