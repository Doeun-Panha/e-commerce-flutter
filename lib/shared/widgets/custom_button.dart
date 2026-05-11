import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget{
  final String text;
  final VoidCallback onPressed;

  final Color? color;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,

    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCustomButton();
  }

  Widget _buildCustomButton(){
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
          ),
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
    );
  }
}