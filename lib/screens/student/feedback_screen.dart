import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeedbackScreen extends StatefulWidget {
  final String? eventId; // nullable now
  final String token;
  final String userId;

  const FeedbackScreen({
    super.key,
    required this.token,
    required this.userId,
    this.eventId, // optional
  });

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  double rating = 3.0;
  bool isSubmitting = false;

  String eventTitle = "General Feedback";
  String? eventBanner;
  String? eventDate;

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) fetchEvent();
  }

  Future<void> fetchEvent() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/events/${widget.eventId}"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          eventTitle = data['title'] ?? "Event Feedback";
          eventBanner = data['bannerImage'];
          eventDate = data['date'];
        });
      }
    } catch (e) {
      print("Error fetching event: $e");
    }
  }

  Future<void> submitFeedback() async {
    if (_feedbackController.text.isEmpty) return;

    setState(() => isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/events/feedback"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: jsonEncode({
          "eventId": widget.eventId ?? "general",
          "userId": widget.userId,
          "rating": rating,
          "comment": _feedbackController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Feedback submitted ✅")),
        );
        Navigator.pop(context);
      } else {
        throw Exception("Failed to submit feedback");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Feedback"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (eventBanner != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(eventBanner!, width: double.infinity, height: 180, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            Text(
              eventTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (eventDate != null)
              Text(
                "Date: $eventDate",
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 20),
            Text("Rate \"$eventTitle\":", style: const TextStyle(fontSize: 18)),
            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: "$rating",
              onChanged: (val) => setState(() => rating = val),
            ),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: "Your Feedback",
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSubmitting ? null : submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
