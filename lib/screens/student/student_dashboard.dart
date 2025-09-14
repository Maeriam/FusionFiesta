import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/student/event_screen.dart';
import '../../screens/student/certificate_screen.dart';
import '../../screens/student/profile_screen.dart';
import '../../screens/student/feedback_screen.dart';


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key}); // no parameters now

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
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
    final screens = [
      EventsScreen(token: token, userId: userId),
      CertificatesScreen(token: token, userId: userId),
      FeedbackScreen(token: token ?? '', userId: userId ?? ''),
      ProfileScreen(name: name ?? '', email: email ?? '', role: role ?? ''),
// NEW
    ];

    final titles = ["Events", "Certificates","Feedback","Profile"];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.workspace_premium), label: "Certificates"),
          BottomNavigationBarItem(icon: Icon(Icons.feedback),label: "Feedback"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
