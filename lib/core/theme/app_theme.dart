import 'package:flutter/material.dart';

class AppTheme {
  static const double borderRadius = 12.0;
  static const double buttonContainerBorderRadius = 24.0;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5EACFF), // The "Source" color
      primary: const Color(0xFF5EACFF),    // Your Main Brand Blue
      onPrimary: Colors.white,             // Color for text/icons ON TOP of blue
      surface: Colors.white,               // Background color for cards/sheets
      error: Colors.redAccent,             // Color for alerts
    ),

    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize:  28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF5EACFF),
      ),
      bodyMedium: TextStyle(
        fontSize: 20,
        color: Color(0xFF616161)
      )
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(double.infinity, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
        foregroundColor: const Color(0xFF616161),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        side: BorderSide(
          color: const Color(0xFFEAEAEA),
          width: 1,
        ),
      )
    )
  );

  //Centralized decoration for all TextFields
  static InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }){
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[100], floatingLabelBehavior: FloatingLabelBehavior.always,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      )
    );
  }
}