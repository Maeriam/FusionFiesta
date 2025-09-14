import 'dart:convert';
import 'package:http/http.dart' as http;


const String baseUrl = 'http://localhost:5000/api';

class ApiService {
  // --- GET ---
  static Future<dynamic> get(String endpoint, {String? token}) async {
    final response = await http
        .get(Uri.parse("$baseUrl/$endpoint"), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    return _processResponse(response);
  }

  // --- POST ---
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final response = await http
        .post(Uri.parse("$baseUrl/$endpoint"),
        headers: _headers(token), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _processResponse(response);
  }

  // --- PUT ---
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    final response = await http
        .put(Uri.parse("$baseUrl/$endpoint"),
        headers: _headers(token), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _processResponse(response);
  }

  // --- DELETE ---
  static Future<dynamic> delete(String endpoint, {String? token}) async {
    final response = await http
        .delete(Uri.parse("$baseUrl/$endpoint"), headers: _headers(token))
        .timeout(const Duration(seconds: 15));
    return _processResponse(response);
  }

  // --- Headers ---
  static Map<String, String> _headers(String? token) {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // --- Process Response ---
  static dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final dynamic body;
  ApiException(this.statusCode, this.body);
  @override
  String toString() => 'ApiException($statusCode): $body';
}
