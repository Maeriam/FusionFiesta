import '../services/api_service.dart';
import '../models/event_model.dart';
import '/config/api_config.dart';
import 'dart:convert'; // for jsonDecode
import 'package:http/http.dart' as http; // for http requests

class EventService {
  /// Fetch all events
  static Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/events'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Event.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  /// Fetch single event by ID
  static Future<Event> getEventById(String id) async {
    final data = await ApiService.get("events/$id");
    return Event.fromJson(data);
  }

  /// Create a new event
  static Future<Event> createEvent(Map<String, dynamic> body, String token) async {
    final data = await ApiService.post("events", body, token: token);
    return Event.fromJson(data);
  }


  /// Register current user for an event and receive certificate
  static Future<Map<String, dynamic>> registerForEvent(String eventId, String token) async {
    final data = await ApiService.post("events/$eventId/register", {}, token: token);
    // data contains: { message, event, certificate }
    return data as Map<String, dynamic>;
  }



  /// Cancel registration for an event
  static Future<String> cancelRegistration(String id, String token) async {
    final data = await ApiService.delete("events/register/$id", token: token);
    return data['message'];
  }

  /// Approve an event (admin only)
  static Future<String> approveEvent(String id, String token) async {
    final data = await ApiService.put("events/approve/$id", {}, token: token);
    return data['message'];
  }

  /// Bookmark an event
  static Future<bool> bookmarkEvent(String eventId, String token) async {
    final data = await ApiService.post("users/bookmark/$eventId", {}, token: token);
    return data['success'] ?? true;
  }

  /// Remove bookmark
  static Future<bool> removeBookmark(String eventId, String token) async {
    final data = await ApiService.delete("users/bookmark/$eventId", token: token);
    return data['success'] ?? true;
  }

  /// Fetch user certificates
  static Future<List<dynamic>> getCertificates(String token) async {
    final data = await ApiService.get("events/certificates", token: token);
    return data as List;
  }

  /// Submit feedback for an event
  static Future<String> submitFeedback(
      String eventId, String feedback, String token) async {
    final data = await ApiService.post(
      "events/feedback",
      {"eventId": eventId, "feedback": feedback},
      token: token,
    );
    return data['message'] ?? "Feedback submitted";
  }

  static Future<Event> updateEvent(String id, Map<String, dynamic> body, String token) async {
    final data = await ApiService.put("events/$id", body, token: token);
    return Event.fromJson(data);
    fetchEvents();
  }

  /// Delete an event (admin only)
  static Future<String> deleteEvent(String id, String token) async {
    final data = await ApiService.delete("events/$id", token: token);
    return data['message'];
  }

  /// Fetch participants of an event
  static Future<List<dynamic>> getEventParticipants(String id, String token) async {
    final data = await ApiService.get("events/$id/participants", token: token);
    return data as List;
  }

}
