import 'package:bot_toast/bot_toast.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/styles/theme/app_theme.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/profile/presentation/view_model/controller/profile_controller.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  SharedPreferenceManager sharedPreferenceManager =
      sl.get<SharedPreferenceManager>();
  bool? isLightMode;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((t) async {
      ref.read(profileProvider.notifier).getInitialThemeMode();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appInitialization = ref.watch(appInitializationProvider);
    final profileController = ref.watch(profileProvider);
    return appInitialization.when(data: (data) {
      final router = ref.watch(goRouterProvider);
      return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Enigma',
        builder: BotToastInit(),
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        darkTheme: darkTheme,
        theme: lightTheme,
        themeMode:
            profileController.isLightMode ? ThemeMode.light : ThemeMode.dark,
      );
    }, error: (e, s) {
      debug("appInitialization error $e");
      return const SizedBox.shrink();
    }, loading: () {
      return const SizedBox.shrink();
    });
  }
}
