import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Color.fromARGB(255, 239, 239, 239),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600),
      displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500),

      bodyLarge: TextStyle(fontSize: 18.0),
      bodyMedium: TextStyle(fontSize: 16.0),
      bodySmall: TextStyle(fontSize: 14.0),

      headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Color.fromARGB(255, 157, 154, 154),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
  );
}