import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/features/chat/data/model/chat_model.dart';
import 'package:enigma/src/features/message/data/model/message_model.dart';
import 'package:enigma/src/features/message/data/repository/message_repository_impl.dart';
import 'package:enigma/src/features/message/domain/dto/message_dto.dart';
import 'package:enigma/src/features/message/domain/repository/message_repository.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/domain/use_cases/base_use_case.dart';

class MessageUseCase extends UseCase<Either<Failure, ChatModel>, MessageDTO> {
  MessageRepository messageRepository = sl.get<MessageRepositoryImpl>();

  @override
  Future<Either<Failure, ChatModel>> call(MessageDTO params) async {
    return await messageRepository.getAllFriendsLastMessage(
      myID: params.myUserID,
      buddyID: params.buddyUserID,
    );
  }
}
