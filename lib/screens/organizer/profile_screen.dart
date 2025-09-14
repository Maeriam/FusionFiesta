import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String role;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "O",
                style: const TextStyle(fontSize: 40, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(email, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Role: $role", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
