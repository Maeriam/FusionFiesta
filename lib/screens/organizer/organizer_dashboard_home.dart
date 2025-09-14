import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrganizerDashboardHome extends StatefulWidget {
  const OrganizerDashboardHome({super.key});

  @override
  State<OrganizerDashboardHome> createState() => _OrganizerDashboardHomeState();
}

class _OrganizerDashboardHomeState extends State<OrganizerDashboardHome> {
  bool isLoading = true;
  int totalEvents = 0;
  int totalRegistrations = 0;
  List<dynamic> upcomingEvents = [];
  String? token;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/events/dashboard"),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("Dashboard response status: ${response.statusCode}");
      print("Dashboard response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          totalEvents = data['eventsCreated']?.length ?? 0;
          totalRegistrations = data['registrationCounts']
              ?.fold(0, (sum, item) => sum + (item['count'] ?? 0)) ??
              0;
          upcomingEvents = data['eventsCreated'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load dashboard");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error loading dashboard: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final textTheme = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome Organizer!", style: textTheme.headlineSmall),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStatCard("Total Events", totalEvents.toString(), Colors.deepPurple),
                const SizedBox(width: 10),
                _buildStatCard("Total Registrations", totalRegistrations.toString(), Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
            Text("Upcoming Events:", style: textTheme.titleMedium),
            const SizedBox(height: 10),
            if (upcomingEvents.isEmpty)
              const Text("No upcoming events."),
            ...upcomingEvents.map((event) => Card(
              child: ListTile(
                title: Text(event['title'] ?? 'Untitled Event'),
                subtitle: Text("📅 ${event['date'] ?? 'N/A'}"),
                trailing: Text("${event['registeredUsers']?.length ?? 0} registrations"),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
