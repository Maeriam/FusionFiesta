import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  late Future<List<Map<String, String>>> _certificatesFuture;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Hardcoded certificates for testing
    final hardcodedCerts = [
      {
        'eventTitle': 'Flutter Workshop',
        'userName': 'John Doe',
      },
      {
        'eventTitle': 'Dart Bootcamp',
        'userName': 'Jane Smith',
      },
      {
        'eventTitle': 'Firebase Seminar',
        'userName': 'Alice Johnson',
      },
    ];

    setState(() {
      _certificatesFuture = Future.value(hardcodedCerts);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _certificatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No certificates found",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final certs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: certs.length,
            itemBuilder: (context, index) {
              final cert = certs[index];
              return Card(
                color: const Color(0xFF262626),
                elevation: 4,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    "Certificate for ${cert['eventTitle']}",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    "Issued to: ${cert['userName']}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download, color: Colors.blueAccent),
                    onPressed: () {
                      // TODO: Implement download logic
                    },
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
