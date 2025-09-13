import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/event_service.dart';

class EventRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  const EventRegistrationScreen({super.key, required this.event});

  @override
  _EventRegistrationScreenState createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  bool isLoading = true;
  bool isRegistering = false;
  Map<String, dynamic>? certificate;

  @override
  void initState() {
    super.initState();
    checkRegistration();
  }

  // Check if user is already registered and fetch certificate
  Future<void> checkRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');

    if (token == null || userId == null) {
      setState(() => isLoading = false);
      return;
    }

    // Check if user is already registered
    final registeredUsers = widget.event['registeredUsers'] as List;
    if (registeredUsers.contains(userId)) {
      // Fetch certificate
      final certificates = await EventService.getCertificates(token);
      final cert = certificates.firstWhere(
              (c) => c['event']['_id'] == widget.event['_id'],
          orElse: () => null);

      setState(() {
        certificate = cert;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  String generateRandomQRCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<void> register() async {
    setState(() => isRegistering = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to register.")),
      );
      setState(() => isRegistering = false);
      return;
    }

    try {
      final response = await EventService.registerForEvent(widget.event['_id'], token);

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
            const Icon(Icons.workspace_premium,
                size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              "Registered!\nQR: ${certificate!['qrCode']}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              "Certificate file: ${certificate!['fileUrl']}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        )
            : ElevatedButton(
          onPressed: isRegistering ? null : register,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple),
          child: isRegistering
              ? const CircularProgressIndicator(
            color: Colors.white,
          )
              : const Text("Confirm Registration"),
        ),
      ),
    );
  }
}
