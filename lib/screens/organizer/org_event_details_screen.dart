import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  final String token;

  const EventDetailScreen({super.key, required this.eventId, required this.token});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Map<String, dynamic>? event;
  bool isLoading = true;
  final TextEditingController _coOrganizerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/events/${widget.eventId}"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          event = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch event details");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  Future<void> updateStatus(String status) async {
    try {
      final response = await http.patch(
        Uri.parse("http://localhost:5000/api/events/${widget.eventId}/status"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({'status': status}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event status updated")),
        );
        await fetchEventDetails();
      } else {
        throw Exception("Failed to update status");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  Future<void> addCoOrganizer() async {
    final email = _coOrganizerController.text.trim();
    if (email.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/events/${widget.eventId}/co-organizers"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({'email': email}),
      );

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Co-organizer added")),
        );
        _coOrganizerController.clear();
        await fetchEventDetails();
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to add co-organizer")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  Future<void> removeCoOrganizer(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://localhost:5000/api/events/${widget.eventId}/co-organizers/$userId"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Co-organizer removed")),
        );
        await fetchEventDetails();
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Failed to remove")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  void showAddCoOrganizerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Co-Organizer"),
        content: TextField(
          controller: _coOrganizerController,
          decoration: const InputDecoration(labelText: "Email"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              addCoOrganizer();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Details"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : event == null
          ? const Center(child: Text("Event not found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event!['title'] ?? "Untitled Event",
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(event!['description'] ?? "",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Text(
              "Date: ${DateFormat.yMMMMd().add_jm().format(DateTime.parse(event!['date']))}",
            ),
            Text("Venue: ${event!['venue'] ?? 'N/A'}"),
            Text("Status: ${event!['status']}"),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => updateStatus("Live"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green),
                  child: const Text("Mark Live"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => updateStatus("Completed"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange),
                  child: const Text("Mark Completed"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Participants:",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            if ((event!['registeredUsers'] ?? []).isEmpty)
              const Text("No participants yet"),
            ...List.generate(event!['registeredUsers']?.length ?? 0,
                    (index) {
                  final participant = event!['registeredUsers'][index];
                  return ListTile(
                    title: Text(participant['name'] ?? "Unnamed"),
                    subtitle: Text(participant['email'] ?? ""),
                  );
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Co-Organizers:",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon:
                  const Icon(Icons.add, color: Colors.deepPurple),
                  onPressed: showAddCoOrganizerDialog,
                )
              ],
            ),
            if ((event!['coOrganizers'] ?? []).isEmpty)
              const Text("No co-organizers yet"),
            ...List.generate(event!['coOrganizers']?.length ?? 0,
                    (index) {
                  final coOrg = event!['coOrganizers'][index];
                  return ListTile(
                    title: Text(coOrg['name'] ?? "Unnamed"),
                    subtitle: Text(coOrg['email'] ?? ""),
                    trailing: IconButton(
                      icon:
                      const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeCoOrganizer(coOrg['_id']),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
