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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Error: $e")));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Error: $e")));
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
          const SnackBar(content: Text("✅ Co-organizer added")),
        );
        _coOrganizerController.clear();
        await fetchEventDetails();
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'] ?? "Failed to add co-organizer")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Error: $e")));
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
          const SnackBar(content: Text("🗑️ Co-organizer removed")),
        );
        await fetchEventDetails();
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(data['message'] ?? "Failed to remove")));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  void showAddCoOrganizerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Co-Organizer"),
        content: TextField(
          controller: _coOrganizerController,
          decoration: const InputDecoration(
            labelText: "Email",
            prefixIcon: Icon(Icons.email),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              addCoOrganizer();
            },
            icon: const Icon(Icons.add),
            label: const Text("Add"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  Widget buildSectionCard({required Widget child}) {
    return Card(
      color: Colors.grey.shade900,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Event Details"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchEventDetails)
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : event == null
          ? const Center(child: Text("Event not found", style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Event Title ---
            Row(
              children: [
                const Icon(Icons.event, size: 28, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event!['title'] ?? "Untitled Event",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              event!['description'] ?? "",
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // --- Event Info ---
            buildSectionCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    title: Text(
                      DateFormat.yMMMMd().add_jm().format(DateTime.parse(event!['date'])),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.place, color: Colors.deepPurple),
                    title: Text("Venue: ${event!['venue'] ?? 'N/A'}",
                        style: const TextStyle(color: Colors.white)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.flag, color: Colors.deepPurple),
                    title: Text("Status: ${event!['status']}",
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Status Buttons ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => updateStatus("Live"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Mark Live"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => updateStatus("Completed"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Mark Completed"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- Participants ---
            Text("Participants", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            if ((event!['registeredUsers'] ?? []).isEmpty)
              const Text("No participants yet", style: TextStyle(color: Colors.white54)),
            ...List.generate(event!['registeredUsers']?.length ?? 0, (index) {
              final participant = event!['registeredUsers'][index];
              return buildSectionCard(
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.deepPurple),
                  title: Text(participant['name'] ?? "Unnamed", style: const TextStyle(color: Colors.white)),
                  subtitle: Text(participant['email'] ?? "", style: const TextStyle(color: Colors.white70)),
                ),
              );
            }),

            const SizedBox(height: 20),

            // --- Co-Organizers ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Co-Organizers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                    onPressed: showAddCoOrganizerDialog),
              ],
            ),
            const SizedBox(height: 8),
            if ((event!['coOrganizers'] ?? []).isEmpty)
              const Text("No co-organizers yet", style: TextStyle(color: Colors.white54)),
            ...List.generate(event!['coOrganizers']?.length ?? 0, (index) {
              final coOrg = event!['coOrganizers'][index];
              return buildSectionCard(
                child: ListTile(
                  leading: const Icon(Icons.person_outline, color: Colors.deepPurple),
                  title: Text(coOrg['name'] ?? "Unnamed", style: const TextStyle(color: Colors.white)),
                  subtitle: Text(coOrg['email'] ?? "", style: const TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeCoOrganizer(coOrg['_id'])),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
