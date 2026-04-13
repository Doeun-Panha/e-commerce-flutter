import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppTheme {
  static const double borderRadius = 12.0;

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