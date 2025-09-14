import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'org_event_details_screen.dart';

class MyEventsScreen extends StatefulWidget {
  final String token;
  final String userId;

  const MyEventsScreen({super.key, required this.token, required this.userId});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<dynamic> myEvents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyEvents();
  }

  Future<void> fetchMyEvents() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/events?organizerId=${widget.userId}"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          myEvents = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch events");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error fetching events: $e")),
      );
    }
  }

  void goToEventDetails(dynamic event) async {
    // Navigate to EventDetailScreen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(eventId: event['_id'], token: widget.token),
      ),
    );
    // Refresh after returning
    fetchMyEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : myEvents.isEmpty
          ? const Center(child: Text("No events created yet"))
          : RefreshIndicator(
        onRefresh: fetchMyEvents,
        child: ListView.builder(
          itemCount: myEvents.length,
          itemBuilder: (context, index) {
            final event = myEvents[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(event['title'] ?? "Untitled"),
                subtitle: Text(
                    "${event['status']} - ${event['registeredUsers']?.length ?? 0} participants"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => goToEventDetails(event),
              ),
            );
          },
        ),
      ),
    );
  }
}
