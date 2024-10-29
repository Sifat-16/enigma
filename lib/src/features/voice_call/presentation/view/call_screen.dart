import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:enigma/src/core/global/global_variables.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/features/message/presentation/view/message_screen.dart';
import 'package:enigma/src/features/voice_call/data/model/call_model.dart';
import 'package:enigma/src/features/voice_call/presentation/view/components/audio_call_interface.dart';
import 'package:enigma/src/features/voice_call/presentation/view_model/call_controller.dart';
import 'package:enigma/src/features/voice_call/presentation/view_model/call_generic.dart';
import 'package:enigma/src/features/voice_call/presentation/view_model/call_state_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// MultiChannel Example
class CallScreen extends ConsumerStatefulWidget {
  /// Construct the [JoinChannelVideo]
  const CallScreen(
      {super.key, required this.callModel, required this.isCalling});

  final bool isCalling;
  final CallModel callModel;
  static const String route = "/call";

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<CallScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((t) async {
      // await ref
      //     .read(callProvider.notifier)
      //     .initiateCallEngine(callModel: widget.callModel);
      if (widget.isCalling) {
        await ref.read(callProvider.notifier).call(callModel: widget.callModel);
      } else {
        await ref
            .read(callProvider.notifier)
            .initiateCallEngine(callModel: widget.callModel);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final call = ref.watch(callProvider);
    final callState = ref.watch(callStateProvider);
    // print("Agora Client ${call.agoraClient}");
    // print("Agora Engine ${call.engine}");
    print("Can be popped for this ${ref.read(goRouterProvider).canPop()}");

    return Scaffold(
        body: call.engine == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Builder(builder: (context) {
                if (callState == CallState.canceled ||
                    callState == CallState.ended) {
                  ref.read(callStateProvider.notifier).state = CallState.none;
                  if (ref.read(goRouterProvider).canPop()) {
                    ref.read(goRouterProvider).pop();
                  } else {
                    ref
                        .read(goRouterProvider)
                        .pushReplacement(MessageScreen.route);
                  }
                  FlutterCallkitIncoming.endAllCalls();
                  try {
                    ref.read(initialCallDataProvider.notifier).state = null;
                  } catch (e) {}
                }

                return SafeArea(
                  child: Stack(
                    children: [
                      // AgoraVideoButtons(client: client),
                      Center(
                        child: _remoteVideo(call, widget.callModel),
                      ),
                      // if (call.muteCamera && call.remoteIdJoined != null)
                      //   AudioCallInterface(callModel: widget.callModel)
                      // else
                      /// Local Video View
                      if (call.muteCamera)
                        Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: 100,
                            height: 150,
                            child: Center(
                              child: call.isJoined
                                  ? AgoraVideoView(
                                      controller: VideoViewController(
                                        rtcEngine: call.engine!,
                                        canvas: const VideoCanvas(uid: 0),
                                      ),
                                    )
                                  : const CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(30)),
                            child: InkWell(
                              onTap: () async {
                                await ref
                                    .read(callProvider.notifier)
                                    .switchCamera();
                              },
                              child: const Icon(
                                Icons.switch_camera,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: context.height * 0.1,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () async {
                                  await ref
                                      .read(callProvider.notifier)
                                      .muteLocalAudioStream();
                                  // print(ref.read(callProvider).muteVoice);
                                },
                                child: Icon(
                                  Icons.mic_off,
                                  color: call.muteVoice
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await ref
                                      .read(callProvider.notifier)
                                      .leaveChannel(
                                          callModel: widget.callModel);
                                  await ref
                                      .read(callProvider.notifier)
                                      .sendCallEndNotification(
                                          callModel: widget.callModel);
                                  if (widget.isCalling) {
                                    container.read(goRouterProvider).pop();
                                  } else {
                                    ref.read(callStateProvider.notifier).state =
                                        CallState.ended;
                                  }
                                },
                                child: const Icon(
                                  Icons.call_end,
                                  color: Colors.red,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await ref
                                      .read(callProvider.notifier)
                                      .muteLocalVideoStream();
                                  // await ref
                                  //     .read(callProvider.notifier)
                                  //     .muteAllRemoteVideoStreams();
                                },
                                child: Icon(
                                  Icons.videocam_off,
                                  color: call.muteCamera
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }));
  }

  Widget _remoteVideo(CallGeneric call, CallModel callModel) {
    /// Remote Video View
    if (call.remoteIdJoined != null && !call.muteAllRemoteVideo) {
      return SafeArea(
        child: Stack(
          children: [

            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: call.engine!,
                canvas: VideoCanvas(uid: call.remoteIdJoined),
                connection:
                    RtcConnection(channelId: widget.callModel.channelId),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                "${call.totalSeconds}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      );
    } else {
      return AudioCallInterface(
        callModel: callModel,
        isCalling: widget.isCalling,
      );
    }
  }
}
