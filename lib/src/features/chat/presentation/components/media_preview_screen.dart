import 'dart:io';

import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:flutter/material.dart';

class MediaPreviewScreen extends StatelessWidget {
  const MediaPreviewScreen({super.key, required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image(
        image: FileImage(file),
        height: context.height * 0.7,
        width: context.width,
        fit: BoxFit.cover,
        alignment: Alignment.bottomCenter,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
      ),
    );
  }
}
