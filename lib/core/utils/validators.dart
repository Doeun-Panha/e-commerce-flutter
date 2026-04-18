import 'package:flutter/material.dart';

class AppValidators{
  /// 1. REQUIRED: Checks for null, empty, or just whitespace strings.
  static String? Function(String?) required({String? message}){
    return (value){
      if(value == null || value.trim().isEmpty){
        return message ?? 'This field is required';
      }
      return null;
    };
  }

  /// 2. NUMBER: Ensures the input is a valid numeric value.
  static String? Function(String?) number({String? message}) {
    return (value) {
      if (value == null || value.isEmpty) return null; // Let 'required' handle empty
      if (double.tryParse(value) == null) {
        return message ?? 'Enter a valid number';
      }
      return null;
    };
  }

  /// 3. MIN VALUE: Checks if a number is at least X (useful for Price/Stock).
  static String? Function(String?) min(double minValue, {String? message}) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final num = double.tryParse(value);
      if (num != null && num < minValue) {
        return message ?? 'Value must be at least $minValue';
      }
      return null;
    };
  }

  /// 4. URL: Updated to follow the factory pattern for consistency.
  static String? Function(String?) url({String? message}) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      final uri = Uri.tryParse(value);
      final isValid = uri != null &&
          uri.hasAbsolutePath &&
          (uri.isScheme('http') || uri.isScheme('https'));
      return isValid ? null : message ?? 'Enter a valid image URL';
    };
  }

  /// 5. COMBINE: The "Engine" that runs multiple validations.
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result; // Stops at the first error found
      }
      return null;
    };
  }

  /// 6. MATCH: Ensures two fields have the same value.
  static String? Function(String?) match(TextEditingController otherController, {String? message}) {
    return (value) {
      if (value == null || value.isEmpty) return null;
      if (value.trim() != otherController.text) {
        return message ?? 'Passwords do not match';
      }
      return null;
    };
  }
}