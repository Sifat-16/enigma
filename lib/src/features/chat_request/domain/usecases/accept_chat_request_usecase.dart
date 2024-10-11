import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/network/responses/success_response.dart';
import 'package:enigma/src/features/chat_request/data/repository/chat_request_repository_impl.dart';
import 'package:enigma/src/features/chat_request/domain/entity/chat_request_entity.dart';
import 'package:enigma/src/features/chat_request/domain/repository/chat_request_repository.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/domain/use_cases/base_use_case.dart';

class AcceptChatRequestUseCase
    extends UseCase<Either<Failure, Success>, ChatRequestEntity> {
  final ChatRequestRepository _chatRequestRepository =
      sl.get<ChatRequestRepositoryImpl>();

  @override
  Future<Either<Failure, Success>> call(ChatRequestEntity params) async {
    Either<Failure, Success> response = await _chatRequestRepository
        .updateRequestStatus(chatRequestEntity: params);
    return response;
  }
}