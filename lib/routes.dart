import 'package:flutter/material.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/auth_check.dart';

// Role Dashboards
import 'screens/student/student_dashboard.dart';
import 'screens/organizer/organizer_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

// Student Screens
import 'screens/student/event_details_screen.dart';
// import 'screens/student/bookmarked_events_screen.dart';

// Organizer Screens
import 'screens/organizer/my_events_screen.dart';
import 'screens/organizer/registrations_screen.dart';
import 'screens/organizer/feedback_list_screen.dart';
import 'screens/organizer/create_event_screen.dart';

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

  // Organizer Screens
  static const String myEvents = '/my-events';
  static const String registrations = '/registrations';
  static const String feedbackList = '/feedback-list';
  static const String createEvent = '/create-event';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authCheck:
        return MaterialPageRoute(builder: (_) => const AuthCheck());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => SignupScreen());

    // Dashboards
      case studentDashboard:
        return MaterialPageRoute(builder: (_) => const StudentDashboard());
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

      // case bookmarkedEvents:
      //   return MaterialPageRoute(builder: (_) => const BookmarkedEventsScreen());

    // Organizer Routes
      case myEvents:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('token') || !args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Token or User ID missing')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => MyEventsScreen(
            token: args['token'],
            userId: args['userId'],
          ),
        );

      case registrations:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('token') || !args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Token or User ID missing')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => RegistrationsScreen(
            token: args['token'],
            userId: args['userId'],
          ),
        );

      case feedbackList:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('token') || !args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Token or User ID missing')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => FeedbackListScreen(
            token: args['token'],
            userId: args['userId'],
          ),
        );

      case createEvent:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('token')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Token missing')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => CreateEventScreen(
            token: args['token'],
            onEventCreated: args['onEventCreated'] ?? () {},
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
