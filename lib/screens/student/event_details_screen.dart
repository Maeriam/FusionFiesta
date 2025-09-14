import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../screens/student/feedback_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Map<String, dynamic>? event;
  bool isLoading = true;
  String? token;
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    fetchEvent();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      userId = user['_id'];
    }
    setState(() {});
  }

  Future<void> fetchEvent() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/events/${widget.eventId}"),
      );
      if (response.statusCode == 200) {
        setState(() {
          event = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load event details");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error fetching event: $e");
    }
  }

  Future<void> registerForEvent() async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/events/register/${widget.eventId}"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully registered for event ✅")),
        );
      } else {
        throw Exception("Failed to register");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const deepPurple = Color(0xFF3E1E68);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : event == null
          ? const Center(
          child: Text("Event not found", style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event!['bannerImage'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  event!['bannerImage'],
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              event!['title'] ?? "",
              style: GoogleFonts.robotoCondensed(
                  fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              event!['description'] ?? "",
              style: GoogleFonts.robotoCondensed(
                  fontSize: 16, color: Colors.grey[400]),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                Text(event!['date'] ?? "No date",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.place, size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                Text(event!['venue'] ?? "No venue",
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: registerForEvent,
              icon: const Icon(Icons.event_available),
              label: const Text("Register"),
              style: ElevatedButton.styleFrom(
                backgroundColor: deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: (token != null && userId != null)
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeedbackScreen(
                      eventId: widget.eventId,
                      token: token!,
                      userId: userId!,
                    ),
                  ),
                );
              }
                  : null,
              icon: const Icon(Icons.feedback),
              label: const Text("Leave Feedback"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
