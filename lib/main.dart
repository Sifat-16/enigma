import 'package:enigma/src/core/app/app.dart';
import 'package:enigma/src/core/global/global_variables.dart';
import 'package:enigma/src/core/utils/restart_widget/restart_widget.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupService();
  runApp(UncontrolledProviderScope(
      container: container, child: RestartWidget(child: const App())));
}

// TODO:
// 1. Implement streams for story, last seen, chat request, pending request, people etc.
// TODO: POLISHING
// 1. make text messages encrypted.
// 2. change notification icons.
