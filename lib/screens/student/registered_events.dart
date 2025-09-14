import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/event_service.dart';
import 'pdf_viewer_screen.dart';

class EventRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  const EventRegistrationScreen({super.key, required this.event});

  @override
  _EventRegistrationScreenState createState() => _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  bool isLoading = true;
  bool isRegistering = false;
  Map<String, dynamic>? certificate;
  String? userId;
  String? userRole;

  @override
  void initState() {
    super.initState();
    initScreen();
  }

  Future<void> initScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    userId = prefs.getString('userId');
    userRole = prefs.getString('role');

    if (token != null && userId != null) {
      final registeredUsers = widget.event['registeredUsers'] as List<dynamic>;
      if (registeredUsers.contains(userId)) {
        final certificates = await EventService.getCertificates(token);
        certificate = certificates.firstWhere(
              (c) => c['event']['_id'] == widget.event['_id'],
          orElse: () => null,
        );
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> register() async {
    if (userRole != "participant") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must upgrade to Participant to register.")),
      );
      return;
    }

    setState(() => isRegistering = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await EventService.registerForEvent(widget.event['_id'], token!);

      setState(() {
        certificate = response['certificate'];
        isRegistering = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response['message'])));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
      setState(() => isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event['title'] ?? "Register"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : certificate != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              "Registered!\nQR: ${certificate!['qrCode'] ?? 'N/A'}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PDFViewerScreen(fileUrl: certificate!['fileUrl']),
                  ),
                );
              },
              child: const Text("Preview Certificate"),
            ),
          ],
        )
            : ElevatedButton(
          onPressed: isRegistering ? null : register,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          child: isRegistering
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Confirm Registration"),
        ),
      ),
    );
  }
}
