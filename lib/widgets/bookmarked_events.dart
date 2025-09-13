import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/student/event_details_screen.dart';

class BookmarkedEventsWidget extends StatefulWidget {
  const BookmarkedEventsWidget({super.key});

  @override
  _BookmarkedEventsWidgetState createState() => _BookmarkedEventsWidgetState();
}

class _BookmarkedEventsWidgetState extends State<BookmarkedEventsWidget> {
  List bookmarkedEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookmarkedEvents();
  }

  Future<void> fetchBookmarkedEvents() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final userData = jsonDecode(response.body);
      setState(() {
        bookmarkedEvents = userData['bookmarkedEvents'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching bookmarks: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookmarkedEvents.isEmpty) {
      return const Text("No bookmarked events yet.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Bookmarked Events",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bookmarkedEvents.length,
            itemBuilder: (context, index) {
              final event = bookmarkedEvents[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailsScreen(eventId: event['_id']),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(right: 10),
                  child: SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            event['title'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Text("Date: ${event['date'].substring(0, 10)}"),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
