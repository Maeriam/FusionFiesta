import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        final data = json.decode(response.body);
        setState(() {
          myEvents = data.isEmpty ? _getHardcodedEvents() : data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch events");
      }
    } catch (e) {
      setState(() {
        myEvents = _getHardcodedEvents(); // fallback
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error fetching events: $e")),
      );
    }
  }

  List<Map<String, dynamic>> _getHardcodedEvents() {
    return [
      {
        "_id": "sample1",
        "title": "Tech Conference 2025",
        "status": "Live",
        "venue": "Lagos Convention Center",
        "date": "2025-09-20T10:00:00.000Z",
        "registeredUsers": List.generate(15, (i) => {"name": "User $i"})
      },
      {
        "_id": "sample2",
        "title": "AI Workshop",
        "status": "Pending",
        "venue": "Zoom Online",
        "date": "2025-09-25T14:00:00.000Z",
        "registeredUsers": List.generate(8, (i) => {"name": "Participant $i"})
      },
      {
        "_id": "sample3",
        "title": "Design Meetup",
        "status": "Completed",
        "venue": "Abuja Hub",
        "date": "2025-08-01T18:00:00.000Z",
        "registeredUsers": List.generate(30, (i) => {"name": "Attendee $i"})
      },
    ];
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case "live":
        color = Colors.green;
        break;
      case "pending":
        color = Colors.orange;
        break;
      case "completed":
        color = Colors.grey;
        break;
      default:
        color = Colors.blueGrey;
    }
    return Chip(
      label: Text(
        status,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("My Events"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : myEvents.isEmpty
          ? const Center(
          child: Text(
            "No events created yet",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ))
          : RefreshIndicator(
        onRefresh: fetchMyEvents,
        color: Colors.deepPurple,
        backgroundColor: Colors.grey.shade900,
        child: ListView.builder(
          itemCount: myEvents.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final event = myEvents[index];
            final status = event['status'] ?? "Unknown";
            final participants = event['registeredUsers']?.length ?? 0;

            return Card(
              color: Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        radius: 28,
                        child: const Icon(Icons.event, color: Colors.deepPurple),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title'] ?? "Untitled Event",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    event['venue'] ?? "Venue TBD",
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.people,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "$participants participants",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatusChip(status),
                          const SizedBox(height: 8),
                          const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.deepPurple),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
