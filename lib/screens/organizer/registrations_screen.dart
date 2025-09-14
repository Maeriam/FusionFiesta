import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationsScreen extends StatefulWidget {
  final String token;
  final String userId;

  const RegistrationsScreen({super.key, required this.token, required this.userId});

  @override
  State<RegistrationsScreen> createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends State<RegistrationsScreen> {
  bool isLoading = true;
  List<dynamic> registrations = [];

  @override
  void initState() {
    super.initState();
    fetchRegistrations();
  }

  Future<void> fetchRegistrations() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/events/registrations?organizerId=${widget.userId}"),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          registrations = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load registrations");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : registrations.isEmpty
          ? const Center(child: Text("No registrations yet"))
          : RefreshIndicator(
        onRefresh: fetchRegistrations,
        child: ListView.builder(
          itemCount: registrations.length,
          itemBuilder: (context, index) {
            final reg = registrations[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(reg['participant']['name'] ?? 'Unnamed'),
                subtitle: Text(
                    "${reg['event']['title'] ?? 'Event'} - ${reg['participant']['email'] ?? ''}"),
              ),
            );
          },
        ),
      ),
    );
  }
}
