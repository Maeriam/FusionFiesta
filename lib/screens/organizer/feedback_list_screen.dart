import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeedbackListScreen extends StatefulWidget {
  final String token;
  final String userId;

  const FeedbackListScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  bool isLoading = true;
  List<dynamic> feedbacks = [];

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  Future<void> fetchFeedbacks() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
            "http://localhost:5000/api/events/feedbacks?organizerId=${widget.userId}"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          feedbacks = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load feedbacks");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        // Fallback dummy feedbacks
        feedbacks = [
          {
            'participant': {'name': 'Alice Johnson'},
            'message': 'Amazing event! Learned so much 🎉',
            'rating': 5,
          },
          {
            'participant': {'name': 'Michael Smith'},
            'message': 'Great networking opportunities, thanks!',
            'rating': 4,
          },
          {
            'participant': {'name': 'Sophia Lee'},
            'message':
            'Venue was too crowded, but speakers were excellent.',
            'rating': 3,
          },
        ];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ Showing hardcoded feedbacks (Error: $e)")),
      );
    }
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return Colors.green;
    if (rating == 3) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Event Feedbacks"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple))
          : feedbacks.isEmpty
          ? const Center(
        child: Text(
          "No feedbacks yet",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchFeedbacks,
        color: Colors.deepPurple,
        backgroundColor: Colors.grey.shade900,
        child: ListView.builder(
          itemCount: feedbacks.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final fb = feedbacks[index];
            final rating = fb['rating'] ?? 0;

            return Card(
              color: Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              margin: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text(
                    fb['participant']['name'][0].toUpperCase(),
                    style: const TextStyle(color: Colors.deepPurple),
                  ),
                ),
                title: Text(
                  fb['participant']['name'] ?? 'Unnamed',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
                subtitle: Text(
                  fb['message'] ?? '',
                  style: const TextStyle(
                      fontSize: 14, color: Colors.white70),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: _getRatingColor(rating)),
                    const SizedBox(width: 4),
                    Text(
                      "$rating",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getRatingColor(rating),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
