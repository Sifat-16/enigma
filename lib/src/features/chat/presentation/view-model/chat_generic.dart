import 'dart:io';

import 'package:enigma/src/core/router/model/initial_data_model.dart';

class ChatGeneric {
  // List<ChatEntity> chats;
  //
  // ChatGeneric({this.chats = const []});
  //
  // ChatGeneric update(List<ChatEntity>? chats) {
  //   return ChatGeneric(chats: chats ?? this.chats);
  // }

  InitialDataModel? incomingChatData;
  bool? isImageUploading;
  bool? isVoiceUploading;
  String? timer;
  File? imageFile;

  ChatGeneric({
    this.incomingChatData,
    this.isImageUploading,
    this.isVoiceUploading,
    this.timer = "Record Starting",
    this.imageFile,
  });

  ChatGeneric update({
    InitialDataModel? incomingChatData,
    bool? isImageUploading,
    bool? isVoiceUploading,
    String? timer,
    File? imageFile,
  }) {
    return ChatGeneric(
      incomingChatData: incomingChatData ?? this.incomingChatData,
      isImageUploading: isImageUploading ?? this.isImageUploading,
      isVoiceUploading: isVoiceUploading ?? this.isVoiceUploading,
      timer: timer ?? this.timer,
      imageFile: imageFile ?? this.imageFile,
    );
  }
}
