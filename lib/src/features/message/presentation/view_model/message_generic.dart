import 'package:enigma/src/features/chat/data/model/chat_model.dart';
import 'package:enigma/src/features/message/data/model/message_model.dart';

class MessageGeneric {
  ChatModel? lastMessages;

  MessageGeneric({this.lastMessages});

  MessageGeneric update({ChatModel? lastMessages}) {
    return MessageGeneric(lastMessages: lastMessages ?? this.lastMessages);
  }
}
