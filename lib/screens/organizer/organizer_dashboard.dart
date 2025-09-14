import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'organizer_dashboard_home.dart';
import 'create_event_screen.dart';
import 'my_events_screen.dart';
import 'feedback_list_screen.dart';
import 'profile_screen.dart';
import '../../providers/theme_provider.dart';

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

    if (userJson != null) {
      final user = jsonDecode(userJson);
      userId = user['_id'] ?? user['id'];
      name = user['name'];
      email = user['email'];
      role = user['role'];
    }

    if (!mounted) return;
    setState(() => loadingUser = false);
  }

  void switchScreen(Widget screen) {
    if (!mounted) return;
    setState(() => currentScreen = screen);
  }

  void openCreateEventScreen() {
    if (token == null || userId == null) return;

    Navigator.pop(context);
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
                    MyEventsScreen(token: token!, userId: userId!),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.deepPurple,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: textColor ?? (isDark ? Colors.white70 : Colors.black87),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: Colors.deepPurple.withOpacity(0.08),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDark;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Organizer Dashboard"),
        backgroundColor: const Color(0xFF262626),
        elevation: 2,
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF262626),
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                margin: EdgeInsets.zero,
                accountName: Text(
                  name ?? "Organizer",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                accountEmail: Text(
                  email ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    name != null && name!.isNotEmpty
                        ? name![0].toUpperCase()
                        : "O",
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3)),
                  ],
                ),
              ),

              // Drawer Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    buildDrawerItem(
                      icon: Icons.dashboard,
                      title: "Dashboard",
                      onTap: () {
                        Navigator.pop(context);
                        switchScreen(const OrganizerDashboardHome());
                      },
                    ),
                    buildDrawerItem(
                      icon: Icons.add,
                      title: "Create Event",
                      onTap: openCreateEventScreen,
                    ),
                    buildDrawerItem(
                      icon: Icons.event,
                      title: "My Events",
                      onTap: () {
                        Navigator.pop(context);
                        if (token != null && userId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyEventsScreen(
                                  token: token!, userId: userId!),
                            ),
                          );
                        }
                      },
                    ),

                    buildDrawerItem(
                      icon: Icons.feedback,
                      title: "Feedback",
                      onTap: () {
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
                    buildDrawerItem(
                      icon: Icons.person,
                      title: "Profile",
                      onTap: () {
                        Navigator.pop(context);
                        switchScreen(ProfileScreen(
                          name: name ?? '',
                          email: email ?? '',
                          role: role ?? '',
                        ));
                      },
                    ),
                    const Divider(color: Colors.white38),

                    // Dark Mode Toggle
                    SwitchListTile(
                      secondary: const Icon(Icons.dark_mode,
                          color: Colors.deepPurple),
                      title: const Text(
                        "Dark Mode",
                        style: TextStyle(color: Colors.white),
                      ),
                      value: isDark,
                      onChanged: (_) {
                        themeNotifier.toggleTheme();
                      },
                    ),

                    buildDrawerItem(
                      icon: Icons.logout,
                      title: "Logout",
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (!mounted) return;
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: loadingUser
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
        )
            : currentScreen,
      ),
    );
  }
}
