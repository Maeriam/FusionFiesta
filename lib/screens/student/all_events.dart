// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class EventService {
//   final String baseUrl = "http://10.0.2.2:5000/api/events"; // replace with live backend
//
//   Future<List<dynamic>> fetchEvents() async {
//     final response = await http.get(Uri.parse(baseUrl));
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception("Failed to load events");
//     }
//   }
//
//   Future<dynamic> fetchEventById(String id) async {
//     final response = await http.get(Uri.parse("$baseUrl/$id"));
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception("Event not found");
//     }
//   }
// }
