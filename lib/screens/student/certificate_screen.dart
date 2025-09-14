import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'pdf_viewer_screen.dart';

class CertificatesScreen extends StatefulWidget {
  final String? token;
  final String? userId;

  const CertificatesScreen({super.key, this.token, this.userId});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  List<dynamic> certificates = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    token = widget.token;
    fetchCertificates();
  }

  Future<void> fetchCertificates() async {
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    try {
      final response = await http.get(
        Uri.parse("http://localhost:5000/api/events/certificates"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          certificates = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load certificates");
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
          const SnackBar(content: Text("Could not open file")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const deepPurple = Color(0xFF3E1E68);

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),


      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : certificates.isEmpty
          ? const Center(
        child: Text("No certificates available",
            style: TextStyle(color: Colors.white)),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: certificates.length,
        itemBuilder: (context, index) {
          final cert = certificates[index];
          final event = cert['event'] ?? {};
          final fileUrl = cert['fileUrl'];

          return Card(
            color: const Color(0xFF2A2A2A),
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              onTap: () {
                if (fileUrl != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PDFViewerScreen(fileUrl: fileUrl)),
                  );
                }
              },
              leading: const Icon(Icons.workspace_premium,
                  color: Colors.amber, size: 32),
              title: Text(
                event['title'] ?? "Certificate",
                style: GoogleFonts.robotoCondensed(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              subtitle: Text(
                "Issued: ${event['date']?.substring(0, 10) ?? 'N/A'}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () {
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