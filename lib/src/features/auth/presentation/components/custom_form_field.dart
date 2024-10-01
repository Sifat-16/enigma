import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.validator,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: SizedBox(
        height: context.height * 0.08,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          obscureText: obscureText,
          validator: validator,
        ),
      ),
    );
  }
}