import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'pdf_viewer_screen.dart';
import '../student/upgrade_form_screen.dart';
import 'feedback_screen.dart';

class EventsScreen extends StatefulWidget {
  final String? token;
  final String? userId;

  const EventsScreen({super.key, this.token, this.userId});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<dynamic> events = [];
  Map<String, dynamic>? selectedEvent;
  bool isLoading = true;
  String? token;
  String? userId;
  String? role;
  final backendUrl = "http://localhost:5000";

  @override
  void initState() {
    super.initState();
    token = widget.token;
    userId = widget.userId;
    loadUserRoleAndEvents();
  }

  Future<void> loadUserRoleAndEvents() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString('role');
    await fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse("$backendUrl/api/events"));
      if (response.statusCode == 200) {
        setState(() {
          events = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error fetching events: $e")),
      );
    }
  }

  Future<void> registerForEvent(Map<String, dynamic> event) async {
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to register.")),
      );
      return;
    }

    if (role != 'participant') {
      final upgraded = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UpgradeToParticipantScreen()),
      );

      if (upgraded == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', 'participant');
        role = 'participant';
        await registerForEvent(event);
      }
      return;
    }

    final alreadyRegistered = (event['registeredUsers'] as List).contains(userId);

    if (alreadyRegistered && event['certificate'] != null) {
      final fileUrl = event['certificate']['fileUrl'];
      if (fileUrl != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PDFViewerScreen(fileUrl: fileUrl)),
        );
        return;
      }
    }

    try {
      final response = await http.post(
        Uri.parse("$backendUrl/api/events/${event['_id']}/register"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Registered successfully!")),
        );

        if (data['certificate'] != null && data['certificate']['fileUrl'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>
                PDFViewerScreen(fileUrl: data['certificate']['fileUrl'])),
          );
        }
        await fetchEvents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to register")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  void showEventDetails(Map<String, dynamic> event) {
    setState(() => selectedEvent = event);
  }

  @override
  Widget build(BuildContext context) {
    const deepPurple = Color(0xFF3E1E68);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),


      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : selectedEvent == null
          ? buildEventList(deepPurple)
          : buildEventDetails(selectedEvent!, deepPurple),
    );

  }

  Widget buildEventList(Color deepPurple) {
    if (events.isEmpty) {
      return const Center(
          child: Text("No events available", style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final alreadyRegistered = (event['registeredUsers'] as List).contains(userId);

        return GestureDetector(
          onTap: () => showEventDetails(event),
          child: Card(
            color: const Color(0xFF262626),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['title'] ?? "Untitled Event",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event['description'] ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (alreadyRegistered)
                    Icon(Icons.workspace_premium, color: deepPurple, size: 28),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildEventDetails(Map<String, dynamic> event, Color deepPurple) {
    final alreadyRegistered = (event['registeredUsers'] as List).contains(userId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event['title'] ?? "Untitled Event",
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text(event['description'] ?? "",
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 20),
          Text("📅 Date: ${event['date'] ?? 'N/A'}", style: const TextStyle(color: Colors.white70)),
          Text("📍 Location: ${event['location'] ?? 'N/A'}", style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => registerForEvent(event),
            style: ElevatedButton.styleFrom(
              backgroundColor: deepPurple,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              alreadyRegistered ? "View Certificate" : "Register",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          if (alreadyRegistered)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FeedbackScreen(
                      token: token ?? '',
                      userId: userId ?? '',
                      eventId: event['_id'],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.feedback),
              label: const Text("Leave Feedback"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
