import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeNotifier() {
    _loadTheme();
  }

  ThemeMode get currentMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDark", _isDark);
    notifyListeners();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool("isDark") ?? true;
    notifyListeners();
  }


  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.white,
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: Colors.deepPurple,
    //   foregroundColor: Colors.white,
    // ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.white,
    ),
  );


  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.deepPurple,
    scaffoldBackgroundColor: Colors.black,
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: Colors.black,
    //   foregroundColor: Colors.deepPurple,
    // ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Colors.black,
    ),
  );
}
