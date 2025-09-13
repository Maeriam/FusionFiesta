import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:5000/api/users/me"));
      if (response.statusCode == 200) {
        setState(() {
          profile = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load profile");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error fetching profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : profile == null
          ? const Center(child: Text("Failed to load profile"))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple[100],
              child: const Icon(Icons.person, size: 50, color: Colors.deepPurple),
            ),
            const SizedBox(height: 16),
            Text(profile!['name'] ?? "Unknown",
                style: GoogleFonts.robotoCondensed(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 8),
            Text(profile!['email'] ?? "No email",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.badge, color: Colors.black),
              title: Text("Role: ${profile!['role'] ?? 'student'}"),
            ),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.black),
              title: Text("Enrolled Events: ${profile!['registeredEvents']?.length ?? 0}"),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement logout
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logout not implemented")),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
            )
          ],
        ),
      ),
    );
  }
}
