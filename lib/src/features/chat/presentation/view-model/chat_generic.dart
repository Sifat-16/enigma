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
  bool? isLoading;

  ChatGeneric({
    this.incomingChatData,
    this.isLoading,
  });

  ChatGeneric update({InitialDataModel? incomingChatData, bool? isLoading}) {
    return ChatGeneric(
      incomingChatData: incomingChatData ?? this.incomingChatData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
