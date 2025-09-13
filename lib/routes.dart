import 'package:flutter/material.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/common/splash_screen.dart';
import 'screens/common/profile_screen.dart';
import 'screens/auth/auth_check.dart';

// Role Dashboards
import 'screens/student/student_dashboard.dart';
import 'screens/organizer/organizer_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

// Events
import 'screens/student/event_details_screen.dart';
import 'screens/student/bookmarked_events_screen.dart'; // ✅ Add this

class Routes {
  static const String splash = '/';
  static const String authCheck = '/auth-check';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';

  // Dashboards
  static const String studentDashboard = '/student-dashboard';
  static const String organizerDashboard = '/organizer-dashboard';
  static const String adminDashboard = '/admin-dashboard';

  // Events
  static const String eventList = '/event-list'; // placeholder
  static const String eventDetail = '/event-detail';
  static const String bookmarkedEvents = '/bookmarked-events';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authCheck:
        return MaterialPageRoute(builder: (_) => const AuthCheck());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());

    // Dashboards
      case studentDashboard:
        return MaterialPageRoute(builder: (_) => StudentDashboard());
      case organizerDashboard:
        return MaterialPageRoute(builder: (_) => OrganizerDashboard());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => AdminDashboard());

    // Events
      case eventDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('eventId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Event ID missing')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => EventDetailsScreen(eventId: args['eventId']),
        );

      case bookmarkedEvents: // ✅ handle route
        return MaterialPageRoute(builder: (_) => const BookmarkedEventsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
