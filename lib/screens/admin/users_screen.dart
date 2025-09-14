import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<Map<String, String>>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Hardcoded users for testing
    final hardcodedUsers = [
      {
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'status': 'Active',
      },
      {
        'name': 'Jane Smith',
        'email': 'jane.smith@example.com',
        'status': 'Inactive',
      },
      {
        'name': 'Alice Johnson',
        'email': 'alice.johnson@example.com',
        'status': 'Active',
      },
      {
        'name': 'Bob Williams',
        'email': 'bob.williams@example.com',
        'status': 'Pending',
      },
    ];

    setState(() {
      _usersFuture = Future.value(hardcodedUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white),
                ));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
                  "No users found",
                  style: TextStyle(color: Colors.white70),
                ));
          }

          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final status = user['status'] ?? "Unknown";

              return Card(
                color: const Color(0xFF262626),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(user['name']!,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(user['email']!,
                      style: const TextStyle(color: Colors.white70)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: status.toLowerCase() == "active"
                          ? Colors.green
                          : (status.toLowerCase() == "inactive"
                          ? Colors.orange
                          : Colors.blueGrey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
