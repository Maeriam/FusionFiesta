import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_event_screen.dart';
import 'participants_screen.dart';
import '../../providers/event_provider.dart';
import '../../models/event_model.dart';

class AdminEventsScreen extends StatefulWidget {
  final String token;

  const AdminEventsScreen({super.key, required this.token});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.fetchEvents();
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final events = provider.events;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: provider.isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      )
          : events.isEmpty
          ? const Center(
        child: Text(
          "No events available",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            color: const Color(0xFF262626),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 16),
              title: Text(
                event.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Text(
                "Status: ${event.approved ? "Approved ✅" : "Pending ⏳"}",
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => handleAction(value, event),
                icon:
                const Icon(Icons.more_vert, color: Colors.white70),
                itemBuilder: (context) => [
                  if (!event.approved)
                    const PopupMenuItem(
                        value: "approve", child: Text("Approve")),
                  const PopupMenuItem(value: "edit", child: Text("Edit")),
                  const PopupMenuItem(
                      value: "delete", child: Text("Delete")),
                  const PopupMenuItem(
                      value: "participants",
                      child: Text("View Participants")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void handleAction(String action, Event event) async {
    final provider = Provider.of<EventProvider>(context, listen: false);

    switch (action) {
      case "approve":
        final success = await provider.approveEvent(event.id, widget.token);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text(success ? "✅ Event approved" : "❌ Failed to approve event"),
          ),
        );
        break;

      case "edit":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditEventScreen(token: widget.token, event: event),
          ),
        );
        break;

      case "delete":
        final success = await provider.deleteEvent(event.id, widget.token);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
            Text(success ? "🗑️ Event deleted" : "❌ Failed to delete event"),
          ),
        );
        break;

      case "participants":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ParticipantsScreen(token: widget.token, eventId: event.id),
          ),
        );
        break;
    }
  }
}
