import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeedbackScreen extends StatefulWidget {
  final String eventId;
  const FeedbackScreen({super.key, required this.eventId});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  double rating = 3.0;
  bool isSubmitting = false;

  Future<void> submitFeedback() async {
    if (_feedbackController.text.isEmpty) return;

    setState(() => isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/api/events/feedback"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "eventId": widget.eventId,
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Rate this event:", style: TextStyle(fontSize: 18)),
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
