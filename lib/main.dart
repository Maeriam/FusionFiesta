import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/event_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const FusionFiestaApp(),
    ),
  );
}

class FusionFiestaApp extends StatelessWidget {
  const FusionFiestaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fusion Fiesta',
      themeMode: themeNotifier.currentMode,
      theme: themeNotifier.lightTheme,
      darkTheme: themeNotifier.darkTheme,
      initialRoute: Routes.authCheck,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
