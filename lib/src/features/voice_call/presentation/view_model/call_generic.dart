import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallGeneric {
  bool isJoined,
      switchCamera,
      switchRender,
      openCamera,
      muteCamera,
      muteAllRemoteVideo,
      muteVoice;

  RtcEngine? engine;

  int? remoteIdJoined;
  int? localUidJoined;

  // AgoraClient? agoraClient;

  CallGeneric(
      {this.isJoined = false,
      this.switchCamera = true,
      this.switchRender = true,
      this.openCamera = true,
      this.muteCamera = true,
      this.muteAllRemoteVideo = false,
      this.muteVoice = false,
      this.remoteIdJoined,
      this.localUidJoined,
      //this.agoraClient,
      this.engine});

  CallGeneric update(
      {bool? isJoined,
      bool? switchCamera,
      bool? switchRender,
      bool? openCamera,
      bool? muteCamera,
      bool? muteAllRemoteVideo,
      bool? muteVoice,
      RtcEngine? engine,
      int? remoteIdJoined,
      int? localUidJoined
      //AgoraClient? agoraClient
      }) {
    return CallGeneric(
      isJoined: isJoined ?? this.isJoined,
      switchCamera: switchCamera ?? this.switchCamera,
      switchRender: switchRender ?? this.switchRender,
      openCamera: openCamera ?? this.openCamera,
      muteCamera: muteCamera ?? this.muteCamera,
      muteVoice: muteVoice ?? this.muteVoice,
      muteAllRemoteVideo: muteAllRemoteVideo ?? this.muteAllRemoteVideo,
      engine: engine ?? this.engine,
      remoteIdJoined: remoteIdJoined ?? this.remoteIdJoined,
      localUidJoined: localUidJoined ?? this.localUidJoined,

      //agoraClient: agoraClient ?? this.agoraClient
    );
  }
}
