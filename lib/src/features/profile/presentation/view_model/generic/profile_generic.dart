import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';

class ProfileGeneric {
  bool isLoading;
  bool isLightMode;
  bool nameEditInProgress;
  bool emailEditInProgress;
  bool phoneNumberEditInProgress;
  ProfileEntity? profileEntity;
  List<ProfileEntity> listOfFriends;
  List<ProfileEntity> listOfPeople;
  List<ProfileEntity> listOfAllProfiles;

  ProfileGeneric({
    this.isLoading = false,
    this.isLightMode = false,
    this.nameEditInProgress = false,
    this.emailEditInProgress = false,
    this.phoneNumberEditInProgress = false,
    this.profileEntity,
    this.listOfFriends = const [],
    this.listOfPeople = const [],
    this.listOfAllProfiles = const [],
  });

  ProfileGeneric update({
    bool? isLoading,
    bool? isLightMode,
    bool? nameEditInProgress,
    bool? emailEditInProgress,
    bool? phoneNumberEditInProgress,
    ProfileEntity? profileEntity,
    List<ProfileEntity>? listOfFriends,
    List<ProfileEntity>? listOfPeople,
    List<ProfileEntity>? listOfAllProfiles,
  }) {
    return ProfileGeneric(
        isLoading: isLoading ?? this.isLoading,
        isLightMode: isLightMode ?? this.isLightMode,
        nameEditInProgress: nameEditInProgress ?? this.nameEditInProgress,
        emailEditInProgress: emailEditInProgress ?? this.emailEditInProgress,
        phoneNumberEditInProgress:
            phoneNumberEditInProgress ?? this.phoneNumberEditInProgress,
        listOfFriends: listOfFriends ?? this.listOfFriends,
        listOfPeople: listOfPeople ?? this.listOfPeople,
        listOfAllProfiles: listOfAllProfiles ?? this.listOfAllProfiles,
        profileEntity: profileEntity ?? this.profileEntity);
  }
}
