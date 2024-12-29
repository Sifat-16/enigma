import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';

class MessageDTO {
  String myUserID;
  String buddyUserID;

  MessageDTO({
    required this.myUserID,
    required this.buddyUserID,
  });
}
