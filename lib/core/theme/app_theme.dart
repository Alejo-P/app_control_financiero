import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    colorScheme:
        ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          cardColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 239, 239, 239),
          brightness: Brightness.light,
        ).copyWith(
          primary: Colors.black,
          secondary: Colors.blue,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSurface: Colors.black87,
        ),
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
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.blue,
      textTheme: ButtonTextTheme.primary,
    ),
    dividerTheme: DividerThemeData(
      thickness: 1,
      space: 1,
      color: Colors.grey[400],
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600),
      displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500),

      bodyLarge: TextStyle(fontSize: 18.0),
      bodyMedium: TextStyle(fontSize: 16.0),
      bodySmall: TextStyle(fontSize: 14.0),

      labelLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.grey[600]),
      labelMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.grey[600]),
      labelSmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: Colors.grey[600]),

      headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue; // Color del thumb cuando el switch está activado
        }
        return Colors.grey; // Color del thumb cuando el switch está desactivado
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.withValues(
            alpha: 0.5,
          ); // Color del track cuando el switch está activado
        }
        return Colors.grey.withValues(
          alpha: 0.5,
        ); // Color del track cuando el switch está desactivado
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.withValues(
            alpha: 0.6,
          ); // Color del track cuando el switch está activado
        }
        return Colors.grey.withValues(
          alpha: 0.6,
        ); // Color del track cuando el switch está desactivado
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          return Colors
              .white; // Color del track cuando el switch está desactivado
        }),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          return Colors
              .black; // Color del track cuando el switch está desactivado
        }),
      ),
    ),
    useMaterial3: true,
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    colorScheme:
        ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          cardColor: Color.fromARGB(255, 48, 48, 48),
          backgroundColor: Color.fromARGB(255, 34, 34, 34),
          brightness: Brightness.dark,
        ).copyWith(
          primary: Colors.white,
          secondary: Colors.blue,
          surface: Color.fromARGB(255, 48, 48, 48),
          onPrimary: Colors.black,
          onSurface: Colors.white70,
        ),
    scaffoldBackgroundColor: Color.fromARGB(255, 34, 34, 34),
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
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.blue,
      textTheme: ButtonTextTheme.primary,
    ),
    dividerTheme: DividerThemeData(
      thickness: 1,
      space: 1,
      color: Colors.grey[700],
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w600),
      displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500),

      bodyLarge: TextStyle(fontSize: 18.0),
      bodyMedium: TextStyle(fontSize: 16.0),
      bodySmall: TextStyle(fontSize: 14.0),

      labelLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.grey[500]),
      labelMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.grey[500]),
      labelSmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: Colors.grey[500]),

      headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue; // Color del thumb cuando el switch está activado
        }
        return Colors.grey; // Color del thumb cuando el switch está desactivado
      }),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.withValues(
            alpha: 0.5,
          ); // Color del track cuando el switch está activado
        }
        return Colors.grey.withValues(
          alpha: 0.5,
        ); // Color del track cuando el switch está desactivado
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.withValues(
            alpha: 0.6,
          ); // Color del track cuando el switch está activado
        }
        return Colors.grey.withValues(
          alpha: 0.6,
        ); // Color del track cuando el switch está desactivado
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          return Colors
              .black; // Color del track cuando el switch está desactivado
        }),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          return Colors.white;
        }),
      ),
    ),
    useMaterial3: true,
  );
}
