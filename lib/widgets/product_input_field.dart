import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ProductInputField extends StatelessWidget{
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNumber;
  final int maxLines;
  final String? hint;
  final String? Function(String?)? validator;

  const ProductInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isNumber = false,
    this.maxLines = 1,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: AppTheme.inputDecoration(label: label, icon: icon, hint: hint),
      validator: validator,
    );
  }
}