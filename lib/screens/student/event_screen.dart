import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<dynamic> events = [];
  Map<String, dynamic>? selectedEvent;
  bool isLoading = true;
  String? token;
  String? userId;

  final String backendUrl = "http://localhost:5000"; // backend URL

  @override
  void initState() {
    super.initState();
    loadTokenAndFetchEvents();
  }

  Future<void> loadTokenAndFetchEvents() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    userId = prefs.getString('userId');
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
      print("❌ Error fetching events: $e");
    }
  }

  Future<void> registerForEvent(String eventId) async {
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to register.")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$backendUrl/api/events/$eventId/register"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Registered successfully!")),
        );

        // Update local events list to show user is registered
        await fetchEvents();
      } else {
        throw Exception("Failed to register");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  void showEventDetails(Map<String, dynamic> event) {
    setState(() {
      selectedEvent = event;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          selectedEvent == null ? "Events" : selectedEvent!['title'],
          style: GoogleFonts.robotoCondensed(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        leading: selectedEvent != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => setState(() => selectedEvent = null),
        )
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : selectedEvent == null
          ? buildEventList()
          : buildEventDetails(selectedEvent!),
    );
  }

  Widget buildEventList() {
    if (events.isEmpty) {
      return const Center(child: Text("No events available"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final alreadyRegistered =
        (event['registeredUsers'] as List).contains(userId);

        return GestureDetector(
          onTap: () => showEventDetails(event),
          child: Card(
            color: Colors.grey[200],
            elevation: 5,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event['title'] ?? "Untitled Event",
                            style: GoogleFonts.robotoCondensed(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.black)),
                        const SizedBox(height: 8),
                        Text(event['description'] ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                  if (alreadyRegistered)
                    const Icon(Icons.workspace_premium,
                        color: Colors.deepPurple, size: 28),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.black, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildEventDetails(Map<String, dynamic> event) {
    final alreadyRegistered = (event['registeredUsers'] as List).contains(userId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event['title'] ?? "Untitled Event",
              style: GoogleFonts.robotoCondensed(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 12),
          Text(event['description'] ?? "",
              style: GoogleFonts.robotoCondensed(
                  fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 20),
          Text("📅 Date: ${event['date'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          Text("📍 Location: ${event['location'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: alreadyRegistered
                ? null
                : () => registerForEvent(event['_id']),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: Text(alreadyRegistered ? "Registered" : "Register"),
          )
        ],
      ),
    );
  }
}
