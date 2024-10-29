import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CallState { none, ended, canceled, onGoing }

final callStateProvider = StateProvider<CallState>((ref) => CallState.none);
