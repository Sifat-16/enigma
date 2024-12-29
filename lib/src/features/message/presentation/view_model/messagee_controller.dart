import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/chat/data/model/chat_model.dart';
import 'package:enigma/src/features/message/data/model/message_model.dart';
import 'package:enigma/src/features/message/domain/dto/message_dto.dart';
import 'package:enigma/src/features/message/domain/usecases/message_use_case.dart';
import 'package:enigma/src/features/message/presentation/view_model/message_generic.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final messageProvider = StateNotifierProvider<MessageController, MessageGeneric>(
  (ref) => MessageController(ref),
);

class MessageController extends StateNotifier<MessageGeneric> {
  MessageController(this.ref) : super(MessageGeneric());
  Ref ref;
  MessageUseCase messageUseCase = sl.get<MessageUseCase>();

  Future<void> getAllFriendsLastMessage({required String buddyID, required String myID}) async {
    MessageDTO messageDTO = MessageDTO(myUserID: myID, buddyUserID: buddyID);
    Either<Failure, ChatModel> response = await messageUseCase.call(messageDTO);
    response.fold(
      (left) {
        debug("DATA: ${left.message}");
      },
      (right) {
        debug("DATA: $right");
        state = state.update(lastMessages: right);
      },
    );
  }
}
