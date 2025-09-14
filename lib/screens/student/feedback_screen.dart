import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeedbackScreen extends StatefulWidget {
  final String? eventId;
  final String token;
  final String userId;

  const FeedbackScreen({
    super.key,
    required this.token,
    required this.userId,
    this.eventId,
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

  final List<Map<String, dynamic>> pastFeedbacks = [
    {"name": "Alice", "rating": 5, "comment": "Amazing event!"},
    {"name": "Bob", "rating": 4, "comment": "Well organized."},
    {"name": "Charlie", "rating": 3, "comment": "It was okay."},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) fetchEvent();
  }

  Future<void> fetchEvent() async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/events/${widget.eventId}"),
        headers: {"Authorization": "Bearer ${widget.token}"},
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
        setState(() {
          pastFeedbacks.insert(0, {
            "name": "You",
            "rating": rating.toInt(),
            "comment": _feedbackController.text
          });
          _feedbackController.clear();
          rating = 3.0;
        });
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

  Widget buildStars(double value, {double size = 20}) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      stars.add(Icon(
        i <= value ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: size,
      ));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    const deepPurple = Color(0xFF3E1E68);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (eventBanner != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  eventBanner!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              eventTitle,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            if (eventDate != null)
              Text(
                "Date: $eventDate",
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 20),

            // Feedback input card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Your Rating:",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () => setState(() => rating = index + 1.0),
                      );
                    }),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _feedbackController,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Your Feedback",
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white38)
                          : const Text(
                        "Submit Feedback",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                "Past Feedbacks",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: pastFeedbacks.map((fb) {
                return SizedBox(
                  width: double.infinity, // Make it take full width
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16), // More spacing between cards
                    padding: const EdgeInsets.all(20), // More padding inside
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fb['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        buildStars(fb['rating'].toDouble(), size: 20),
                        const SizedBox(height: 8),
                        Text(
                          fb['comment'],
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

          ],
        ),
      ),
    );
  }
}
