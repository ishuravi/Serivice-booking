import 'package:flutter/material.dart';
import '../../colors/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final int? maxLines; // Added for multiline support
  final bool readOnly; // New property for read-only mode

  const CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.inputType = TextInputType.text,
    this.validator,
    this.maxLines = 1, // Default is single-line input
    this.readOnly = false, // Default is editable

  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: validator,
        maxLines: maxLines, // Allow multiline input
        readOnly: readOnly, // Prevents user input
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.darkBlue),
          prefixIcon: Icon(icon, color: AppColors.darkBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
