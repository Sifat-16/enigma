import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.validator,
    this.obscureText = false,
    this.helperText,
    this.onChanged,
    this.onPressed,
  });

  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final FormFieldValidator<String> validator;
  final String? helperText;
  final Function(String)? onChanged;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: SizedBox(
        height: context.height * 0.08,
        child: TextFormField(
          controller: controller,
          onChanged: onChanged ?? (value) {},
          decoration: InputDecoration(
            labelText: labelText,
            helperText: helperText,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            suffixIcon: onPressed != null
                ? InkWell(
                    onTap: onPressed,
                    child: Icon(
                      Icons.remove_red_eye,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : null,
            errorStyle: const TextStyle(
              height: 1,
            ),
          ),
          obscureText: obscureText,
          validator: validator,
        ),
      ),
    );
  }
}
