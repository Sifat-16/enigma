import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/network/responses/success_response.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/chat/domain/dto/chat_room_dto.dart';
import 'package:enigma/src/features/chat/domain/entity/chat_entity.dart';
import 'package:enigma/src/features/chat/domain/usecases/add_chat_usecase.dart';
import 'package:enigma/src/features/chat/domain/usecases/get_chat_usecase.dart';
import 'package:enigma/src/features/chat/presentation/view-model/chat_generic.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/features/profile/domain/usecases/read_profile_usecase.dart';
import 'package:enigma/src/shared/data/model/push_body_model/push_body_model.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/domain/dto/fcm_dto.dart';
import 'package:enigma/src/shared/domain/dto/profile_picture_dto.dart';
import 'package:enigma/src/shared/domain/use_cases/profile_picture_usecase.dart';
import 'package:enigma/src/shared/domain/use_cases/send_push_message_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatProvider = StateNotifierProvider<ChatController, ChatGeneric>(
  (ref) => ChatController(ref),
);

class ChatController extends StateNotifier<ChatGeneric> {
  ChatController(this.ref) : super(ChatGeneric());
  Ref ref;
  int seconds = 0;
  Timer? timer;

  AddChatUsecase addChatUsecase = sl.get<AddChatUsecase>();
  GetChatUsecase getChatUsecase = sl.get<GetChatUsecase>();
  ImageMediaUsecase imageMediaUsecase = sl.get<ImageMediaUsecase>();
  SendPushMessageUsecase sendPushMessageUsecase = sl.get<SendPushMessageUsecase>();
  ReadProfileUseCase readProfileUseCase = sl.get<ReadProfileUseCase>();

  Future<void> addChat(ChatEntity chatEntity) async {
    Either<Failure, Success> response = await addChatUsecase.call(chatEntity);
    response.fold(
      (left) {
        BotToast.showText(text: left.message);
      },
      (right) {
        ref.read(chatProvider.notifier).sendMessageNotification(chatEntity);
      },
    );
  }

  Future<Stream<List<ChatEntity>>> getChat({required String myUid, required String friendUid}) async {
    ChatRoomDto chatRoomDto = ChatRoomDto(myUid: myUid, friendUid: friendUid);
    final response = await getChatUsecase.call(chatRoomDto);
    // debug("From Chat Controller ${response.runtimeType}");
    return response;
  }

  Future<Either<Failure, Success>> sendMessageNotification(ChatEntity chatEntity) async {
    Either<Failure, ProfileEntity> senderResponse = await readProfileUseCase.call(chatEntity.sender ?? "");
    Either<Failure, ProfileEntity> receiverResponse =
        await readProfileUseCase.call(chatEntity.receiver ?? "");

    ProfileEntity? sender, receiver;

    senderResponse.fold((left) => null, (right) => sender = right);
    receiverResponse.fold((left) => null, (right) => receiver = right);
    FCMDto fcmDto = FCMDto(
      recipientToken: receiver?.deviceToken ?? "",
      title: sender?.name ?? "",
      body: chatEntity.content ?? "${chatEntity.mediaLink}",
      imageUrl: "",
      data: PushBodyModel(
        showNotification: true,
        type: "message",
        body: jsonEncode(sender?.toJson()),
      ),
    );
    Either<Failure, Success> response = await sendPushMessageUsecase.call(fcmDto);
    return response;
  }

  Future<String?> addImageMedia(
      {required File file,
      required String directory,
      required String fileName,
      MediaType mediaType = MediaType.text}) async {
    if (mediaType == MediaType.image) {
      state = state.update(isImageUploading: true);
    } else if (mediaType == MediaType.voice) {
      state = state.update(isVoiceUploading: true);
    }
    String? url;
    ImageMediaDto params = ImageMediaDto(
      file: file,
      directory: directory,
      fileName: fileName,
    );
    Either<Failure, Success> response = await imageMediaUsecase.call(params);
    response.fold((left) {
      BotToast.showText(text: left.message);
    }, (right) {
      debug(right.message);
      url = right.message;
    });
    state = state.update(isImageUploading: false, isVoiceUploading: false);
    return url;
  }

  void startVoiceTimer() {
    try {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          seconds += 1;
          String hour = (seconds ~/ 3600).toString().padLeft(2, '0');
          String minute = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
          String second = (seconds % 60).toString().padLeft(2, '0');
          debug("Timer $hour : $minute : $second");
          state = state.update(timer: "$hour : $minute : $second");
        },
      );
    } catch (e) {
      debug("Timer Failed $e");
    }
  }

  void stopVoiceTimer() {
    seconds = 0;
    state = state.update(timer: "Record Starting");
    timer?.cancel();
    timer = null;
  }
}
