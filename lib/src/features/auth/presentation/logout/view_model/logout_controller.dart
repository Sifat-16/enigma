import 'package:bot_toast/bot_toast.dart';
import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_keys.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/network/responses/success_response.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/features/auth/domain/usecases/logout_usecase.dart';
import 'package:enigma/src/features/auth/presentation/auth_screen/view/auth_screen.dart';
import 'package:enigma/src/features/auth/presentation/logout/view_model/logout_generic.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/domain/use_cases/base_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final logoutProvider = StateNotifierProvider<LogoutController, LogoutGeneric>(
    (ref) => LogoutController(ref));

class LogoutController extends StateNotifier<LogoutGeneric> {
  LogoutController(this.ref) : super(LogoutGeneric());
  Ref ref;

  LogoutUseCase logoutUseCase = sl.get<LogoutUseCase>();
  final SharedPreferenceManager preferenceManager = sl.get();
  Future<bool> logout() async {
    state = state.update(isLoading: true);
    bool isSuccess = false;
    Either<Failure, Success> response = await logoutUseCase.call(NoParams());
    response.fold(
      (left) {
        BotToast.showText(text: left.message);
      },
      (right) {
        BotToast.showText(text: "See you again!");
        isSuccess = true;
        preferenceManager.insertValue<bool>(
            key: SharedPreferenceKeys.AUTH_STATE, data: false);
        ref.read(goRouterProvider).go(AuthScreen.route);
      },
    );
    state = state.update(isLoading: false);
    return isSuccess;
  }
}
