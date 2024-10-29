import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_keys.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/router/router.dart';
// import 'package:agora_uikit/agora_uikit.dart';
import 'package:enigma/src/core/rtc/rtc_config.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/voice_call/data/model/call_model.dart';
import 'package:enigma/src/features/voice_call/presentation/view/call_screen.dart';
import 'package:enigma/src/features/voice_call/presentation/view_model/call_generic.dart';
import 'package:enigma/src/shared/data/model/push_body_model/push_body_model.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/domain/dto/fcm_dto.dart';
import 'package:enigma/src/shared/domain/use_cases/send_push_message_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

final callProvider =
    StateNotifierProvider.autoDispose<CallController, CallGeneric>(
        (ref) => CallController(ref));

class CallController extends StateNotifier<CallGeneric> {
  CallController(this.ref) : super(CallGeneric());
  Ref ref;
  SharedPreferenceManager sharedPreferenceManager = sl.get<SharedPreferenceManager>();

  SendPushMessageUsecase sendPushMessageUsecase = SendPushMessageUsecase();

  RtcEngineEventHandler? _rtcEngineEventHandler;

  Future<void> call({required CallModel callModel}) async {
    callModel.token ??= await RTCConfig.fetchToken(
        callModel.uid ?? 0, callModel.channelId ?? "");

    debug("call model stat ${callModel.toJson()}");

    await initiateCallEngine(
      callModel: callModel,
    );
    sendCallNotification(callModel: callModel);
  }

  sendCallNotification({required CallModel callModel}) {
    sendPushMessageUsecase.call(FCMDto(
        recipientToken: callModel.receiverToken ?? "",
        title: "Enigma Call",
        body: "Call came from ${callModel.senderName}",
        imageUrl: callModel.senderAvatar ?? "",
        data: PushBodyModel(
            showNotification: false,
            type: "incoming_call",
            body: jsonEncode(callModel.toJson()))));
  }

  Future<void> initiateCallEngine({required CallModel callModel}) async {
    await [Permission.microphone, Permission.camera].request();
    callModel.token ??= await RTCConfig.fetchToken(
        callModel.uid ?? 0, callModel.channelId ?? "");

    RtcEngine engine = createAgoraRtcEngine();

    print("Before engine initialize: ${RTCConfig.APP_ID}");

    await engine.initialize(
      const RtcEngineContext(
          appId: RTCConfig.APP_ID,
          channelProfile: ChannelProfileType.channelProfileCommunication),
    );
    engine.registerEventHandler(RtcEngineEventHandler(
      onError: (ErrorCodeType err, String msg) {
        print('[onError] err: $err, msg: $msg');
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
        debug(
            '[onJoinChannelSuccess] connection: ${connection.localUid} elapsed: $elapsed');

        state =
            state.update(isJoined: true, localUidJoined: connection.localUid);

        // try {
        //   state.engine?.startPreview();
        // } catch (e) {}
      },
      onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
        debug(
            '[onUserJoined] connection: ${connection.toJson()} remoteUid: $rUid elapsed: $elapsed');

        state = state.update(remoteIdJoined: rUid);
      },
      onUserOffline:
          (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
        debug(
            '[onUserOffline] connection: ${connection.toJson()}  rUid: $rUid reason: $reason');
        // leaveChannel();
        state = state.update(remoteIdJoined: null);
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        debug(
            '[onLeaveChannel] connection: ${connection.toJson()} stats: ${stats.toJson()}');
        // state = state.update(remoteIdJoined: null);
        // rootNavigatorKey.currentContext!.pop();
        state = state.update(isJoined: false);
      },
      onRemoteVideoStateChanged: (RtcConnection connection, int remoteUid,
          RemoteVideoState stat, RemoteVideoStateReason reason, int elapsed) {
        print("Remote Video Camera State:${stat.name}");
        print("Remote video state reason: ${reason.name}");
        print("Remote video state elapse: ${elapsed}");
        if(stat == RemoteVideoState.remoteVideoStateDecoding){
          state = state.update(muteAllRemoteVideo: true);
        } else {
          state = state.update(muteAllRemoteVideo: false);
        }
        debug(
            '[onRemoteVideoStateChanged] connection: ${connection.toJson()} remoteUid: $remoteUid state: $state reason: $reason elapsed: $elapsed');
      },
    ));

    engine.getConnectionState();

    await engine.enableVideo();
    await engine.startPreview();

    state = state.update(
      engine: engine, /*agoraClient: agoraClient*/
    );

    joinChannel(callModel: callModel);
  }

  Future<void> joinChannel({required CallModel callModel}) async {
    try {
      await state.engine?.leaveChannel();
    } catch (e) {}
    await state.engine?.joinChannel(
      token: callModel.token ?? "",
      channelId: callModel.channelId ?? "",
      uid: 0,
      options: const ChannelMediaOptions(
          // Automatically subscribe to all video streams
          autoSubscribeVideo: true,
          // Automatically subscribe to all audio streams
          autoSubscribeAudio: true,
          // Publish camera video
          publishCameraTrack: true,
          // Publish microphone audio
          publishMicrophoneTrack: true,
          // Set user role to clientRoleBroadcaster (broadcaster) or clientRoleAudience (audience)
          clientRoleType: ClientRoleType.clientRoleBroadcaster),
    );
  }

  Future<void> leaveChannel({required CallModel callModel}) async {
    await state.engine?.leaveChannel();
    state.update(
        openCamera: true, muteCamera: false, muteAllRemoteVideo: false);

    dispose();
  }

  Future<void> switchCamera() async {
    await state.engine?.switchCamera();
    state = state.update(switchCamera: !state.switchCamera);
  }

  openCamera() async {
    await state.engine?.enableLocalVideo(!state.openCamera);
    state = state.update(openCamera: !state.openCamera);
  }

  muteLocalAudioStream() async {
    await state.engine?.muteLocalAudioStream(!state.muteVoice);
    state = state.update(muteVoice: !state.muteVoice);
  }

  muteLocalVideoStream() async {
    await state.engine?.muteLocalVideoStream(!state.muteCamera);

    state = state.update(muteCamera: !state.muteCamera);
  }

  muteAllRemoteVideoStreams() async {
    await state.engine?.muteAllRemoteVideoStreams(!state.muteAllRemoteVideo);
    state = state.update(muteAllRemoteVideo: !state.muteAllRemoteVideo);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    //state.engine?.unregisterEventHandler(_rtcEngineEventHandler!);
    state.engine?.leaveChannel();
    // state.engine?.release();
    super.dispose();
  }

  void showCallDialog({required PushBodyModel pushBodyModel}) {
    showDialog(
      context: rootNavigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: const Text("Incoming Call"),
          actions: [
            TextButton(
                onPressed: () {
                  CallModel callModel = CallModel.fromJson(
                    jsonDecode(pushBodyModel.body),
                  );

                  context.pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CallScreen(callModel: callModel, isCalling: false),
                    ),
                  );
                },
                child: const Text("Accept")),
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("Decline"),
            ),
          ],
        );
        // return Consumer(
        //   builder: (context, rf, child) {
        //     final controller = rf.watch(callProvider);
        //     return controller.isJoined
        //         ? AlertDialog(
        //             title: const Text("Incoming Call"),
        //             actions: [
        //               TextButton(
        //                   onPressed: () {
        //                     CallModel callModel = CallModel.fromJson(
        //                       jsonDecode(pushBodyModel.body),
        //                     );
        //
        //                     context.pop();
        //                     Navigator.push(
        //                       context,
        //                       MaterialPageRoute(
        //                         builder: (context) => CallScreen(
        //                             callModel: callModel, isCalling: false),
        //                       ),
        //                     );
        //                   },
        //                   child: const Text("Accept")),
        //               TextButton(
        //                 onPressed: () {
        //                   context.pop();
        //                 },
        //                 child: const Text("Decline"),
        //               ),
        //             ],
        //           )
        //         : const SizedBox();
        //   },
        // );
      },
    );
  }

  sendCallEndNotification({required CallModel callModel}) {
    print("${callModel.receiverName}- ${callModel.receiverToken}");
    String userUid = sharedPreferenceManager.getValue(key: SharedPreferenceKeys.USER_UID);
    try {
      if(callModel.senderUid == userUid) {
        print("sending to receiver");
        sendPushMessageUsecase.call(FCMDto(
            recipientToken: callModel.receiverToken ?? "",
            title: "",
            body: "",
            data: PushBodyModel(
                type: "call_end", body: jsonEncode(callModel.toJson())),
            imageUrl: ""));
      } else {
        print("sending to sender");
        sendPushMessageUsecase.call(FCMDto(
            recipientToken: callModel.senderToken ?? "",
            title: "",
            body: "",
            data: PushBodyModel(
                type: "call_end", body: jsonEncode(callModel.toJson())),
            imageUrl: ""));
      }
    }catch(e) {
      print(e);
    }
  }
}
