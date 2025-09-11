import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_dashboard.dart';

class AppRoutes {
  static const login = '/login';
  static const studentDashboard = '/student-dashboard';

  static Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),
    studentDashboard: (_) => const StudentDashboard(),
  };
}
