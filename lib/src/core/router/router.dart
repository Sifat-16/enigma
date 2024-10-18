import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/auth/presentation/auth_screen/view/auth_screen.dart';
import 'package:enigma/src/features/auth/presentation/login/view/login_screen.dart';
import 'package:enigma/src/features/auth/presentation/signup/view/signup_screen.dart';
import 'package:enigma/src/features/chat/presentation/view/chat_screen.dart';
import 'package:enigma/src/features/chat_request/presentation/view/friends_screen.dart';
import 'package:enigma/src/features/chat_request/presentation/view/people_screen.dart';
import 'package:enigma/src/features/message/presentation/view/message_screen.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/features/profile/presentation/view/profile_screen.dart';
import 'package:enigma/src/features/profile/presentation/view/settings_screen.dart';
import 'package:enigma/src/features/splash/presentation/view/splash_screen.dart';
import 'package:enigma/src/features/story/presentation/view/story_preview_screen.dart';
import 'package:enigma/src/features/story/presentation/view/story_screen.dart';
import 'package:enigma/src/shared/view/bottom_nav_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final goRouterProvider = Provider(
  (ref) {
    return GoRouter(
      initialLocation: SplashScreen.route,
      observers: [BotToastNavigatorObserver()],
      routes: [
        GoRoute(
            path: "/",
            builder: (context, state) {
              return MessageScreen();
            }),
        GoRoute(
          path: SplashScreen.route,
          builder: (context, state) {
            return const SplashScreen();
          },
        ),
        GoRoute(
          path: ProfileScreen.route,
          builder: (context, state) {
            debug("path parameter : ${state.pathParameters}");
            ProfileEntity profileEntity = state.extra as ProfileEntity;
            return ProfileScreen(
              data: profileEntity,
            );
          },
        ),
        GoRoute(
          path: StoryScreen.route,
          builder: (context, state) {
            return StoryScreen(
              data: state.pathParameters["index"] ?? "0",
            );
          },
        ),
        GoRoute(
          path: StoryPreviewScreen.route,
          builder: (context, state) {
            debug("path parameter : ${state.pathParameters}");
            File? mediaFile = state.extra as File?;
            return StoryPreviewScreen(
              mediaFile: mediaFile ?? File(""),
            );
          },
        ),
        GoRoute(
          path: AuthScreen.route,
          builder: (context, state) {
            return const AuthScreen();
          },
        ),
        GoRoute(
          path: LoginScreen.route,
          builder: (context, state) {
            return LoginScreen();
          },
        ),
        GoRoute(
          path: SignupScreen.route,
          builder: (context, state) {
            return SignupScreen();
          },
        ),
        GoRoute(
          path: ChatScreen.route,
          builder: (context, state) {
            // debug("path parameter : ${state.pathParameters}");
            ProfileEntity profileEntity = state.extra as ProfileEntity;
            return ChatScreen(
              profileEntity: profileEntity,
            );
          },
        ),
        GoRoute(
            path: FriendsScreen.route,
            builder: (context, state) {
              return FriendsScreen(
                data: state.pathParameters,
              );
            }),
        StatefulShellRoute.indexedStack(
            branches: [
              StatefulShellBranch(
                  initialLocation: MessageScreen.setRoute(),
                  routes: [
                    GoRoute(
                        path: MessageScreen.route,
                        builder: (context, state) {
                          return MessageScreen();
                        }),
                  ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: "/people",
                  builder: (context, state) {
                    return PeopleScreen(data: state.pathParameters);
                  },
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                    path: "/settings",
                    builder: (context, state) {
                      return SettingsScreen();
                    }),
              ])
            ],
            builder: (context, state, navigationShell) {
              return BottomNavScreen(navigationShell: navigationShell);
            })
      ],
    );
  },
);
