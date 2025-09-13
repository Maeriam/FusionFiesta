import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // for downloading/opening files
import 'package:shared_preferences/shared_preferences.dart'; // for storing JWT

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  _CertificatesScreenState createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  List<dynamic> certificates = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    loadTokenAndFetchCertificates();
  }

  Future<void> loadTokenAndFetchCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token'); // get JWT token
    if (token != null) {
      await fetchCertificates(token!);
    } else {
      setState(() => isLoading = false);
      print("❌ No token found. User might not be logged in.");
    }
  }

  Future<void> fetchCertificates(String token) async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/events/certificates"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          certificates = data;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load certificates: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error fetching certificates: $e");
    }
  }

  Future<void> downloadFile(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open file")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Certificates"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : certificates.isEmpty
          ? const Center(child: Text("No certificates available"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          final cert = certificates[index];
          final event = cert['event'] ?? {};
          return Card(
            color: Colors.grey[100],
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.workspace_premium,
                  color: Colors.deepPurple, size: 32),
              title: Text(event['title'] ?? "Certificate",
                  style: GoogleFonts.robotoCondensed(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              subtitle: Text(
                  "Issued: ${event['date']?.substring(0, 10) ?? 'N/A'}",
                  style:
                  const TextStyle(fontSize: 14, color: Colors.grey)),
              trailing: IconButton(
                icon: const Icon(Icons.download, color: Colors.black),
                onPressed: () {
                  final fileUrl = cert['fileUrl'];
                  if (fileUrl != null) downloadFile(fileUrl);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
