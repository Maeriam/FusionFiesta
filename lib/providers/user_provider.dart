import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];

  List<User> get users => _users;

  Future<void> fetchUsers(String token) async {
    _users = await UserService.getAllUsers(token);
    notifyListeners();
  }

  Future<bool> bookmarkEvent(String eventId, String token) async {
    try {
      await UserService.bookmarkEvent(eventId, token);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeBookmark(String eventId, String token) async {
    try {
      await UserService.removeBookmark(eventId, token);
      return true;
    } catch (_) {
      return false;
    }
  }
}
