import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/services/event_service.dart';
import '/models/event_model.dart';

class BookmarkedEventsScreen extends StatefulWidget {
  const BookmarkedEventsScreen({super.key});

  @override
  State<BookmarkedEventsScreen> createState() => _BookmarkedEventsScreenState();
}

class _BookmarkedEventsScreenState extends State<BookmarkedEventsScreen> {
  List<Event> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedEvents();
  }

  Future<void> _loadBookmarkedEvents() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;

    setState(() => _loading = true);
    try {
      final allEvents = await EventService.fetchEvents();
      setState(() {
        _events = allEvents
            .where((e) => auth.bookmarks.contains(e.id))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading bookmarks: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bookmarked Events")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? const Center(child: Text("No bookmarked events yet."))
          : RefreshIndicator(
        onRefresh: _loadBookmarkedEvents,
        child: ListView.builder(
          itemCount: _events.length,
          itemBuilder: (context, index) {
            final event = _events[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              child: ListTile(
                title: Text(event.title),
                subtitle: Text(event.date.toString()),
                trailing: const Icon(Icons.bookmark, color: Colors.deepPurple),
              ),
            );
          },
        ),
      ),
    );
  }
}
