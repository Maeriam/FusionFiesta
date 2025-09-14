import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/event_provider.dart';

class ParticipantsScreen extends StatefulWidget {
  final String token;
  final String eventId;

  const ParticipantsScreen({super.key, required this.token, required this.eventId});

  @override
  State<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends State<ParticipantsScreen> {
  bool _isLoading = true;
  List<dynamic> participants = [];

  @override
  void initState() {
    super.initState();
    loadParticipants();
  }

  Future<void> loadParticipants() async {
    try {
      final provider = Provider.of<EventProvider>(context, listen: false);
      final data = await provider.getParticipants(widget.eventId, widget.token);
      setState(() {
        participants = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error loading participants: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Participants"),
        backgroundColor: Colors.black87,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : participants.isEmpty
          ? const Center(
        child: Text(
          "No participants registered yet",
          style: TextStyle(color: Colors.white70),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: participants.length,
        itemBuilder: (context, index) {
          final user = participants[index];
          return Card(
            color: const Color(0xFF262626),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                user['name'] ?? "Unnamed",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user['email'] ?? "No email",
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (user['status'] == "confirmed") ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user['status'] ?? "",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
