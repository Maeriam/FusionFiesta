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
  int totalEvents = 5;
  int totalRegistrations = 3;
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
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(
          "Dashboard", // or whatever dynamic title you want
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // ✅ white text
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black87, // solid black87 background
        elevation: 2, // optional shadow
      )
      ,
      body: RefreshIndicator(
        onRefresh: loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.deepPurple,
                    child: Text("🎉", style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Welcome Back, Organizer!",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 22),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "“Great events start with great organizers!” 💡",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Stats
              Row(
                children: [
                  _buildStatCard("Total Events", totalEvents.toString()),
                  const SizedBox(width: 12),
                  _buildStatCard("Registrations", totalRegistrations.toString()),
                ],
              ),
              const SizedBox(height: 30),

              // Upcoming Events
              const Text(
                "Upcoming Events",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 12),
              if (upcomingEvents.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFF262626),
                  ),
                  child: const Center(
                    child: Text(
                      "No upcoming events yet 🎈",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              else
                ...upcomingEvents.map(
                      (event) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event, color: Colors.deepPurple, size: 30),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'] ?? 'Untitled Event',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "📅 ${event['date'] ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(
                            "${event['registeredUsers']?.length ?? 0} regs",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.deepPurple,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
