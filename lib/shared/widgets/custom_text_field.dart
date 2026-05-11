import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget{
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNumber;
  final bool isPassword;
  final int maxLines;
  final String? hint;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isNumber = false,
    this.isPassword = false,
    this.maxLines = 1,
    this.hint,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      maxLines: isPassword ? 1 : maxLines,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : (maxLines > 1 ? TextInputType.multiline: TextInputType.text),
      textInputAction: textInputAction,
      decoration: AppTheme.inputDecoration(
          label: label,
          icon: icon,
          hint: hint,
      ).copyWith(suffixIcon: suffixIcon),
      validator: validator,
      onChanged: onChanged,
    );
  }
}