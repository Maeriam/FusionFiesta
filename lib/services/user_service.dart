import '../models/user_model.dart';
import 'api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


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

  static Future<Map<String, dynamic>> upgradeToParticipant(
      String enrolmentNumber,
      String department,
      String collegeIdProof,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse("http://localhost:5000/api/auth/upgrade"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "enrolmentNumber": enrolmentNumber,
        "department": department,
        "collegeIdProof": collegeIdProof,
      }),
    );

    return jsonDecode(response.body);
  }
}

