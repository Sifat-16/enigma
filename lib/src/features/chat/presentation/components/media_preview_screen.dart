import 'dart:io';

import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:flutter/material.dart';

class MediaPreviewScreen extends StatelessWidget {
  const MediaPreviewScreen({super.key, required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: FileImage(file),
      width: context.width,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
    );
  }
}
