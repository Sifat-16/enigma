import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/features/chat/data/model/chat_model.dart';
import 'package:enigma/src/features/message/data/model/message_model.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';

abstract class MessageRepository {
  Future<Either<Failure, ChatModel>> getAllFriendsLastMessage({required String buddyID, required String myID});
}