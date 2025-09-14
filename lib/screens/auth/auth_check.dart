import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '/routes.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated && authProvider.user != null) {
          final role = authProvider.user!.role;

          if (role == 'student') {
            Future.microtask(() => Navigator.pushReplacementNamed(context, Routes.studentDashboard));
          } else if (role == 'organizer') {
            Future.microtask(() => Navigator.pushReplacementNamed(context, Routes.organizerDashboard));
          } else if (role == 'admin') {
            Future.microtask(() => Navigator.pushReplacementNamed(context, Routes.adminDashboard));
          }
        } else {
          Future.microtask(() => Navigator.pushReplacementNamed(context, Routes.login));
        }


        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
