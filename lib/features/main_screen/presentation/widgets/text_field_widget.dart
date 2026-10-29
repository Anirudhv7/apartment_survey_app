import 'package:flutter/material.dart';

class ApartmentTextField extends StatelessWidget {
  final bool readOnly;
  final String label;
  final TextInputType keyboardType;
  final TextEditingController controller;
  const ApartmentTextField({
    super.key,
    required this.label,
    this.keyboardType = TextInputType.text,
    required this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        readOnly: readOnly,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
