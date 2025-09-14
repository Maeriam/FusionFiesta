import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventStatsScreen extends StatefulWidget {
  final String eventId;
  final String token;

  const EventStatsScreen({super.key, required this.eventId, required this.token});

  @override
  State<EventStatsScreen> createState() => _EventStatsScreenState();
}

class _EventStatsScreenState extends State<EventStatsScreen> {
  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/events/${widget.eventId}/stats"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          stats = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch stats");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  double getAverageRating() {
    if (stats == null || stats!['feedbacks'] == null || stats!['feedbacks'].isEmpty) return 0.0;
    final feedbacks = stats!['feedbacks'] as List;
    final total = feedbacks.fold<double>(0, (sum, f) => sum + (f['rating'] ?? 0));
    return total / feedbacks.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Statistics"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stats == null
          ? const Center(child: Text("No statistics available"))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Participants: ${stats!['participantCount'] ?? 0}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text("Average Rating: ${getAverageRating().toStringAsFixed(1)} / 5",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text("Feedback Comments:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if ((stats!['feedbacks'] as List).isEmpty)
              const Text("No feedback yet")
            else
              Expanded(
                child: ListView.builder(
                  itemCount: (stats!['feedbacks'] as List).length,
                  itemBuilder: (context, index) {
                    final f = stats!['feedbacks'][index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text("Rating: ${f['rating']}"),
                        subtitle: Text(f['comment'] ?? ""),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
