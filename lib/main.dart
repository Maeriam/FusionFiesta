import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';
import 'screens/auth/auth_check.dart';

void main() {
  runApp(const FusionFiestaApp());
}

class FusionFiestaApp extends StatelessWidget {
  const FusionFiestaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fusion Fiesta',
        theme: ThemeData.light(),
        initialRoute: Routes.authCheck,
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}
