import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  static Future<List<User>> getAllUsers(String token) async {
    final data = await ApiService.get("auth", token: token);
    return (data as List).map((u) => User.fromJson(u)).toList();
  }

  static Future<String> bookmarkEvent(String eventId, String token) async {
    final data = await ApiService.post("auth/bookmark/$eventId", {}, token: token);
    return data['message'];
  }

  static Future<String> removeBookmark(String eventId, String token) async {
    final data = await ApiService.delete("auth/bookmark/$eventId", token: token);
    return data['message'];
  }
}
