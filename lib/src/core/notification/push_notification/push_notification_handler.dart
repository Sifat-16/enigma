import 'dart:convert';

import 'package:enigma/src/core/global/global_variables.dart';
import 'package:enigma/src/core/notification/local_notification/local_notification_handler.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/features/chat/presentation/view/chat_screen.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/features/voice_call/data/model/call_model.dart';
import 'package:enigma/src/features/voice_call/presentation/view_model/call_controller.dart';
import 'package:enigma/src/features/voice_call/presentation/view_model/call_state_controller.dart';
import 'package:enigma/src/shared/data/model/push_body_model/push_body_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

@pragma("vm:entry-point")
enum AppMode { FOREGROUND, BACKGROUND, TERMINATED, REVIVED }

@pragma("vm:entry-point")
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.data}");
  print("Runtimetype: ${message.data.runtimeType}");
  await Firebase.initializeApp();
  PushNotificationHandler.handleMessage(message, AppMode.TERMINATED);
}

@pragma("vm:entry-point")
class PushNotificationHandler {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  PushNotificationHandler() {
    init();
  }

  init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    /// Foreground State
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print("APP FROM FOREGROUND");
        handleMessage(message, AppMode.FOREGROUND);
      },
    );

    /// Background State
    FirebaseMessaging.onMessageOpenedApp.listen(
      (data) {
        print("APP FROM BACKGROUND");
        handleMessage(data, AppMode.BACKGROUND);
      },
    );
  }

  static Future<RemoteMessage?> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    print("APP REVIVED");
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(initialMessage, AppMode.REVIVED);
    }
    return initialMessage;
  }

  static void handleMessage(RemoteMessage message, AppMode appMode) async {
    Map<String, dynamic> data = message.data;
    PushBodyModel pushBodyModel = PushBodyModel.fromJson(data);
    // debug(message.data["type"]);
    if (appMode == AppMode.FOREGROUND) {
      print("Handle for FOREGROUND");
      if (pushBodyModel.type == 'incoming_call' ||
          pushBodyModel.type == 'call_end') {
        if (pushBodyModel.type == 'incoming_call') {
          container.read(callProvider.notifier).showCallDialog(
                pushBodyModel: pushBodyModel,
              );
        } else {
          await FlutterCallkitIncoming.endAllCalls();
          container.read(callStateProvider.notifier).state = CallState.ended;
        }
      } else {
        LocalNotificationHandler.showLocalNotification(
            title: message.notification?.title ?? "",
            body: message.notification?.body ?? "",
            pushBodyModel: pushBodyModel);
      }
    } else if (appMode == AppMode.BACKGROUND) {
      print("Handle for BACKGROUND");
      if (pushBodyModel.type == "incoming_call") {
        CallModel callModel =
            CallModel.fromJson(jsonDecode(pushBodyModel.body));
        showCallkitIncoming(callModel);
      } else if (pushBodyModel.type == "message") {
        print("in message");
        container.read(goRouterProvider).push(ChatScreen.route,
            extra: ProfileEntity.fromJson(jsonDecode(pushBodyModel.body)));
      } else if (pushBodyModel.type == 'call_end') {
        try {
          CallModel callModel =
              CallModel.fromJson(jsonDecode(pushBodyModel.body));
        } catch (e) {}

        container.read(callStateProvider.notifier).state = CallState.ended;
        await FlutterCallkitIncoming.endAllCalls();
      }
    } else if (appMode == AppMode.TERMINATED) {
      print("Handle for TERMINATED");
      if (pushBodyModel.type == "incoming_call") {
        CallModel callModel =
            CallModel.fromJson(jsonDecode(pushBodyModel.body));
        showCallkitIncoming(callModel);
      } else if (pushBodyModel.type == "message") {
        print("in message");
      } else if (pushBodyModel.type == 'call_end') {
        try {
          CallModel callModel =
              CallModel.fromJson(jsonDecode(pushBodyModel.body));
        } catch (e) {}
        await FlutterCallkitIncoming.endAllCalls();
      }
    } else if (appMode == AppMode.REVIVED) {
      print("Handle for REVIVED");
      /*if (pushBodyModel.type == "incoming_call") {
        CallModel callModel =
            CallModel.fromJson(jsonDecode(pushBodyModel.body));
        showCallkitIncoming(callModel);
      } else */
      if (pushBodyModel.type == "message") {
        print("in message");
        container.read(goRouterProvider).push(ChatScreen.route,
            extra: ProfileEntity.fromJson(jsonDecode(pushBodyModel.body)));
      } else if (pushBodyModel.type == 'call_end') {
        try {
          CallModel callModel =
              CallModel.fromJson(jsonDecode(pushBodyModel.body));
        } catch (e) {}
        await FlutterCallkitIncoming.endAllCalls();
      }
    }
  }

  static void showCallkitIncoming(CallModel callModel) async {
    final params = CallKitParams(
      id: callModel.channelId,
      nameCaller: '${callModel.senderName}',
      appName: 'Enigma',
      avatar: '${callModel.senderAvatar}',
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        // callbackText: 'Call back',
      ),
      extra: callModel.toJson(),
      // android: const AndroidParams(
      //   isCustomNotification: true,
      //   isShowLogo: false,
      //   ringtonePath: 'system_ringtone_default',
      //   backgroundColor: '#0955fa',
      //   backgroundUrl: 'assets/test.png',
      //   actionColor: '#4CAF50',
      //   textColor: '#ffffff',
      // ),
      // ios: const IOSParams(
      //   iconName: 'CallKitLogo',
      //   handleType: '',
      //   supportsVideo: true,
      //   maximumCallGroups: 2,
      //   maximumCallsPerCallGroup: 1,
      //   audioSessionMode: 'default',
      //   audioSessionActive: true,
      //   audioSessionPreferredSampleRate: 44100.0,
      //   audioSessionPreferredIOBufferDuration: 0.005,
      //   supportsDTMF: true,
      //   supportsHolding: true,
      //   supportsGrouping: false,
      //   supportsUngrouping: false,
      //   ringtonePath: 'system_ringtone_default',
      // ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }
}
