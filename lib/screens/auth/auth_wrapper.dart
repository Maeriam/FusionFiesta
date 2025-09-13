// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../core/services/auth_services.dart';
// import '../student/student_dashboard.dart';
// import '../organizer/organizer_dashboard.dart';
// import '../admin/admin_dashboard.dart';
// import 'login_screen.dart';
//
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final AuthService _authService = AuthService();
//
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//
//         // ✅ If user is logged in, check role
//         if (snapshot.hasData) {
//           final user = snapshot.data!;
//           return FutureBuilder<String?>(
//             future: _authService.getUserRole(user.uid),
//             builder: (context, roleSnapshot) {
//               if (roleSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Scaffold(
//                   body: Center(child: CircularProgressIndicator()),
//                 );
//               }
//
//               if (roleSnapshot.hasError || !roleSnapshot.hasData) {
//                 return const LoginScreen();
//               }
//
//               switch (roleSnapshot.data) {
//                 case "organizer":
//                   return const OrganizerDashboard();
//                 case "admin":
//                   return const AdminDashboard();
//                 default:
//                   return const StudentDashboard();
//               }
//             },
//           );
//         }
//
//         // ❌ No user logged in
//         return const LoginScreen();
//       },
//     );
//   }
// }
