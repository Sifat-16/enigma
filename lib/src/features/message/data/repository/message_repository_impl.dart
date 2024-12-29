import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/features/chat/data/model/chat_model.dart';
import 'package:enigma/src/features/message/data/data_source/remote/message_remote_data_source.dart';
import 'package:enigma/src/features/message/data/model/message_model.dart';
import 'package:enigma/src/features/message/domain/repository/message_repository.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';

class MessageRepositoryImpl extends MessageRepository {
  final MessageRemoteDataSource _messageRemoteDataSource = MessageRemoteDataSource();

  @override
  Future<Either<Failure, ChatModel>> getAllFriendsLastMessage(
      {required String buddyID, required String myID}) async {
    Either<Failure, ChatModel> lastMessages =
        await _messageRemoteDataSource.getAllFriendsLastMessage(buddyID: buddyID, myID: myID);

    return lastMessages;
  }
}
