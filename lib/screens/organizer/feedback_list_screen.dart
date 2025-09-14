import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeedbackListScreen extends StatefulWidget {
  final String token;
  final String userId;

  const FeedbackListScreen({super.key, required this.token, required this.userId});

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
        Uri.parse("http://localhost:5000/api/events/feedbacks?organizerId=${widget.userId}"),
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
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : feedbacks.isEmpty
          ? const Center(child: Text("No feedbacks yet"))
          : RefreshIndicator(
        onRefresh: fetchFeedbacks,
        child: ListView.builder(
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final fb = feedbacks[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(fb['participant']['name'] ?? 'Unnamed'),
                subtitle: Text(fb['message'] ?? ''),
                trailing: Text(fb['rating'] != null ? "⭐ ${fb['rating']}" : ""),
              ),
            );
          },
        ),
      ),
    );
  }
}
