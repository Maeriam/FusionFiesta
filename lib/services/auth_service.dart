import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthService {
  /// Register a new user
  static Future<String> register(
      String name,
      String email,
      String password,
      String role,
      ) async {
    final data = await ApiService.post(
      "auth/register",
      {
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      },
    );

    // Assuming your backend returns a 'message' on successful registration
    return data['message'] ?? "Registration successful";
  }

  /// Login user
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await ApiService.post(
      "auth/login",
      {
        "email": email,
        "password": password,
      },
    );

    // data usually contains token + user info
    return data;
  }

  /// Get logged-in user's profile
  static Future<User> getProfile(String token) async {
    final data = await ApiService.get(
      "auth/me",
      token: token,
    );

    return User.fromJson(data);
  }
}
