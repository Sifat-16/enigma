import 'package:bot_toast/bot_toast.dart';
import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_keys.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/auth/domain/dto/login_dto.dart';
import 'package:enigma/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:enigma/src/features/auth/presentation/login/view_model/login_generic.dart';
import 'package:enigma/src/features/message/presentation/view/message_screen.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/features/profile/presentation/view_model/controller/profile_controller.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginProvider = StateNotifierProvider<LoginController, LoginGeneric>((ref) => LoginController(ref));

class LoginController extends StateNotifier<LoginGeneric> {
  LoginController(this.ref) : super(LoginGeneric());
  Ref ref;

  LoginUseCase loginUseCase = sl.get<LoginUseCase>();
  final SharedPreferenceManager preferenceManager = sl.get();

  Future<bool> login({required String email, required String password}) async {
    state = state.update(isLoading: true);
    bool isSuccess = false;
    LoginDto params = LoginDto(email: email, password: password);
    Either<Failure, User> response = await loginUseCase.call(params);
    response.fold(
      (left) {
        BotToast.showText(text: left.message);
      },
      (right) async {
        BotToast.showText(text: "Welcome to Enigma");
        final String? deviceToken = await FirebaseMessaging.instance.getToken();

        preferenceManager.insertValue<bool>(key: SharedPreferenceKeys.AUTH_STATE, data: true);
        preferenceManager.insertValue<String>(key: SharedPreferenceKeys.USER_UID, data: right.uid);
        preferenceManager.insertValue<String>(key: SharedPreferenceKeys.USER_EMAIL, data: right.email ?? "");

        await ref.read(profileProvider.notifier).readProfile(right.uid);
        ProfileEntity userProfile = ref.read(profileProvider).profileEntity ?? ProfileEntity();
        userProfile.isActive = true;
        userProfile.deviceToken = deviceToken;
        if (userProfile.email != right.email) userProfile.email = right.email;
        await ref.read(profileProvider.notifier).updateProfile(userProfile);
        preferenceManager.insertValue<String>(
            key: SharedPreferenceKeys.USER_NAME, data: userProfile.name ?? "");
        isSuccess = true;
        ref.read(goRouterProvider).go(
              MessageScreen.setRoute(),
            );
      },
    );
    state = state.update(isLoading: false);
    return isSuccess;
  }



}
