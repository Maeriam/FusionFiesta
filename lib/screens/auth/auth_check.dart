import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '/routes.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('ff_token');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (token != null) {
      authProvider.fetchProfile().then((_) {
        final user = authProvider.user;
        if (user != null) {
          if (user.role == 'student') {
            Navigator.pushReplacementNamed(context, Routes.studentDashboard);
          } else if (user.role == 'organizer') {
            Navigator.pushReplacementNamed(context, Routes.organizerDashboard);
          } else if (user.role == 'admin') {
            Navigator.pushReplacementNamed(context, Routes.adminDashboard);
          }
        } else {
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      });
    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
