import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/student/event_screen.dart';
import '../../screens/student/certificate_screen.dart';
import '../../screens/student/profile_screen.dart';
import '../../screens/student/feedback_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String? token;
  String? userId;
  String? name;
  String? email;
  String? role;

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
      userId = user['_id'];
      name = user['name'];
      email = user['email'];
      role = user['role'];
    }
    setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const deepPurple = Color(0xFF3E1E68);
    final screens = [
      EventsScreen(token: token, userId: userId),
      CertificatesScreen(token: token, userId: userId),
      FeedbackScreen(token: token ?? '', userId: userId ?? ''),
      ProfileScreen(name: name ?? '', email: email ?? '', role: role ?? ''),
    ];

    final titles = ["Events", "Certificates", "Feedback", "Profile"];

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, // removes back arrow
        backgroundColor: Colors.black87,   // <-- solid black87 background
        // remove flexibleSpace entirely if not needed
      ),


        body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: Padding(
          key: ValueKey<int>(_selectedIndex),
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: screens[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: deepPurple,
            unselectedItemColor: Colors.grey[400],
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF262626),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 8,
            items: [
              BottomNavigationBarItem(
                icon: AnimatedScale(
                  scale: _selectedIndex == 0 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.event),
                ),
                label: "Events",
              ),
              BottomNavigationBarItem(
                icon: AnimatedScale(
                  scale: _selectedIndex == 1 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.workspace_premium),
                ),
                label: "Certificates",
              ),
              BottomNavigationBarItem(
                icon: AnimatedScale(
                  scale: _selectedIndex == 2 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.feedback),
                ),
                label: "Feedback",
              ),
              BottomNavigationBarItem(
                icon: AnimatedScale(
                  scale: _selectedIndex == 3 ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.person),
                ),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
