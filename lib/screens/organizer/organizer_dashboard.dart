import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'organizer_dashboard_home.dart';
import 'create_event_screen.dart';
import 'my_events_screen.dart';
import 'registrations_screen.dart';
import 'feedback_list_screen.dart';
import 'profile_screen.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  String? token;
  String? userId;
  String? name;
  String? email;
  String? role;

  Widget currentScreen = const OrganizerDashboardHome();
  bool loadingUser = true;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    final userJson = prefs.getString('user');
    print('Loaded user JSON from prefs: $userJson');

    if (userJson != null) {
      final user = jsonDecode(userJson);
      print('Decoded user object: $user');
      userId = user['_id'] ?? user['id'];
      name = user['name'];
      email = user['email'];
      role = user['role'];
    }

    if (!mounted) return;
    setState(() => loadingUser = false);
  }

  // Swap body screen safely
  void switchScreen(Widget screen) {
    if (!mounted) return;
    setState(() => currentScreen = screen);
  }

  // Open Create Event with callback
  void openCreateEventScreen() {
    print('Tapped Create Event: token=$token, userId=$userId');
    if (token == null || userId == null) return;

    Navigator.pop(context); // close drawer first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateEventScreen(
          token: token!,
          onEventCreated: () {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      MyEventsScreen(token: token!, userId: userId!)),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Organizer Dashboard"),
        backgroundColor: Colors.deepPurple,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(name ?? "Organizer"),
                accountEmail: Text(email ?? ""),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    name != null && name!.isNotEmpty
                        ? name![0].toUpperCase()
                        : "O",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                decoration: const BoxDecoration(color: Colors.deepPurple),
              ),

              // Dashboard
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text("Dashboard"),
                onTap: () {
                  print('Tapped Dashboard');
                  Navigator.pop(context);
                  switchScreen(const OrganizerDashboardHome());
                },
              ),

              // Create Event
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("Create Event"),
                onTap: openCreateEventScreen,
              ),

              // My Events
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text("My Events"),
                onTap: () {
                  print('Tapped My Events: token=$token, userId=$userId');
                  Navigator.pop(context);
                  if (token != null && userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MyEventsScreen(token: token!, userId: userId!),
                      ),
                    );
                  }
                },
              ),

              // Registrations
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text("Registrations"),
                onTap: () {
                  print('Tapped Registrations: token=$token, userId=$userId');
                  Navigator.pop(context);
                  if (token != null && userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RegistrationsScreen(token: token!, userId: userId!),
                      ),
                    );
                  }
                },
              ),

              // Feedback
              ListTile(
                leading: const Icon(Icons.feedback),
                title: const Text("Feedback"),
                onTap: () {
                  print('Tapped Feedback: token=$token, userId=$userId');
                  Navigator.pop(context);
                  if (token != null && userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            FeedbackListScreen(token: token!, userId: userId!),
                      ),
                    );
                  }
                },
              ),

              // Profile
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Profile"),
                onTap: () {
                  print('Tapped Profile');
                  Navigator.pop(context);
                  switchScreen(ProfileScreen(
                    name: name ?? '',
                    email: email ?? '',
                    role: role ?? '',
                  ));
                },
              ),

              const Divider(),

              // Logout
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onTap: () async {
                  print('Tapped Logout');
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (!mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),

      body: loadingUser
          ? const Center(child: CircularProgressIndicator())
          : currentScreen,
    );
  }
}
