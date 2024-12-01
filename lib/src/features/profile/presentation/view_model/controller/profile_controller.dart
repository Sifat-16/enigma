import 'package:bot_toast/bot_toast.dart';
import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_keys.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/network/remote/firebase/firebase_handler.dart';
import 'package:enigma/src/core/network/remote/firebase/model/firebase_where_model.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/auth/presentation/login/view/login_screen.dart';
import 'package:enigma/src/features/chat_request/presentation/view_model/chat_request_controller.dart';
import 'package:enigma/src/features/profile/domain/dto/filter_dto.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/features/profile/domain/usecases/create_profile_usecase.dart';
import 'package:enigma/src/features/profile/domain/usecases/read_all_people_usecase.dart';
import 'package:enigma/src/features/profile/domain/usecases/read_all_profile_usecase.dart';
import 'package:enigma/src/features/profile/domain/usecases/read_profile_usecase.dart';
import 'package:enigma/src/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:enigma/src/features/profile/presentation/view_model/generic/profile_generic.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/domain/use_cases/base_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider =
    StateNotifierProvider<ProfileController, ProfileGeneric>(
        (ref) => ProfileController(ref));

class ProfileController extends StateNotifier<ProfileGeneric> {
  ProfileController(this.ref) : super(ProfileGeneric());
  Ref ref;
  SharedPreferenceManager sharedPreferenceManager =
      sl.get<SharedPreferenceManager>();

  CreateProfileUseCase createProfileUseCase = sl.get<CreateProfileUseCase>();
  ReadProfileUseCase readProfileUseCase = sl.get<ReadProfileUseCase>();
  UpdateProfileUseCase updateProfileUseCase = sl.get<UpdateProfileUseCase>();
  ReadAllPeopleUseCase readAllPeopleUseCase = sl.get<ReadAllPeopleUseCase>();
  ReadAllProfileUseCase readAllProfileUseCase = sl.get<ReadAllProfileUseCase>();

  Future<bool> createProfile(ProfileEntity profileEntity) async {
    bool isSuccess = false;
    Either<Failure, ProfileEntity> response =
        await createProfileUseCase.call(profileEntity);
    response.fold(
      (left) {
        BotToast.showText(text: left.message);
      },
      (right) {
        BotToast.showText(text: "Profile Created Successfully");
        isSuccess = true;
        ref.read(goRouterProvider).go(LoginScreen.setRoute());
      },
    );
    return isSuccess;
  }

  updateProfile(ProfileEntity profileEntity) async {
    Either<Failure, ProfileEntity> response =
        await updateProfileUseCase.call(profileEntity);
    response.fold(
      (left) {
        BotToast.showText(text: left.message);
      },
      (right) {
        BotToast.showText(text: "Profile Updated Successfully");
      },
    );
  }

  readProfile(String uid) async {
    ProfileEntity profileEntity = ProfileEntity();
    state = state.update(isLoading: true);
    Either<Failure, ProfileEntity> response =
        await readProfileUseCase.call(uid);
    response.fold((left) {
      BotToast.showText(text: left.message);
    }, (right) {
      state = state.update(profileEntity: right);
    });
    state = state.update(isLoading: false);
  }

  Future<bool> readAllPeople() async {
    state = state.update(isLoading: true);
    // TODO: impement sembast and store profileEntity and call uid from the ProfileEntity
    FirebaseWhereModel whereModel = FirebaseWhereModel(
      field: "uid",
      whereNotIn: [FirebaseHandler.auth.currentUser?.uid ?? ""],
    );
    FilterDto params = FilterDto(firebaseWhereModel: whereModel);
    bool isSuccess = false;
    Either<Failure, List<ProfileEntity>> response =
        await readAllPeopleUseCase.call(params);
    response.fold(
      (left) {
        BotToast.showText(text: left.message);
      },
      (right) {
        List<ProfileEntity> people = filterAllPeople(right);
        state = state.update(listOfPeople: people);

        isSuccess = true;
      },
    );
    state = state.update(isLoading: false);
    return isSuccess;
  }

  Future<bool> readAllProfile() async {
    state = state.update(isLoading: true);
    bool isSuccess = false;
    Either<Failure, List<ProfileEntity>> response =
        await readAllProfileUseCase.call(NoParams());
    response.fold(
      (left) {
        BotToast.showText(text: left.message);
      },
      (right) {
        state = state.update(listOfAllProfiles: right);
        isSuccess = true;
      },
    );
    state = state.update(isLoading: false);
    return isSuccess;
  }

  Future<void> fetchAllFriendsProfileData(Set<String> allUid) async {
    FirebaseWhereModel whereModel = FirebaseWhereModel(
      field: "uid",
      whereIn: allUid.toList(),
    );
    FilterDto params = FilterDto(firebaseWhereModel: whereModel);
    Either<Failure, List<ProfileEntity>> response =
        await readAllPeopleUseCase.call(params);
    response.fold((left) {
      BotToast.showText(text: left.message);
    }, (right) {
      state = state.update(listOfFriends: right);
    });
  }

  List<ProfileEntity> filterAllPeople(List<ProfileEntity> people) {
    List<ProfileEntity> chatRequests =
        ref.read(chatRequestProvider).listOfChatRequest;
    List<ProfileEntity> pendingRequests =
        ref.read(chatRequestProvider).listOfPendingRequest;
    List<ProfileEntity> friends = state.listOfFriends;

    // removing chat requests from people
    Set<String?> chatRequestsUIds = chatRequests.map((e) => e.uid).toSet();
    Set<String?> pendingRequestsUIds =
        pendingRequests.map((e) => e.uid).toSet();
    Set<String?> friendsUIds = friends.map((e) => e.uid).toSet();
    people.removeWhere((person) => chatRequestsUIds.contains(person.uid));
    people.removeWhere((person) => pendingRequestsUIds.contains(person.uid));
    people.removeWhere((person) => friendsUIds.contains(person.uid));

    return people;
  }

  toggleProfileEdit(String field) {
    switch (field) {
      case "name":
        {
          state = state.update(nameEditInProgress: !state.nameEditInProgress);
          break;
        }
      case "email":
        {
          state = state.update(emailEditInProgress: !state.emailEditInProgress);
          break;
        }
      case "phoneNumber":
        {
          state = state.update(
              phoneNumberEditInProgress: !state.phoneNumberEditInProgress);
          break;
        }
    }
  }

  toggleThemeMode({required bool isLightMode}) {
    state = state.update(isLightMode: isLightMode);
  }

  getInitialThemeMode() {
    bool isLightMode = sharedPreferenceManager.getValue(
        key: SharedPreferenceKeys.IS_LIGHT_MODE);
    state = state.update(isLightMode: isLightMode);
    debug("in controller $isLightMode");
  }
}
