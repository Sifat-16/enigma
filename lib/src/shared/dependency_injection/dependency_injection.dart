import 'package:enigma/firebase_options.dart';
import 'package:enigma/src/core/database/local/sembast/sembast_db_config.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/notification/local_notification/local_notification_handler.dart';
import 'package:enigma/src/core/notification/push_notification/push_notification_handler.dart';
import 'package:enigma/src/features/auth/data/repository/auth_repository_impl.dart';
import 'package:enigma/src/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:enigma/src/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:enigma/src/features/auth/domain/usecases/login_usecase.dart';
import 'package:enigma/src/features/auth/domain/usecases/logout_usecase.dart';
import 'package:enigma/src/features/auth/domain/usecases/signup_usecase.dart';
import 'package:enigma/src/features/chat/data/repository/chat_repository_impl.dart';
import 'package:enigma/src/features/chat/domain/usecases/add_chat_usecase.dart';
import 'package:enigma/src/features/chat/domain/usecases/get_chat_usecase.dart';
import 'package:enigma/src/features/chat_request/data/repository/chat_request_repository_impl.dart';
import 'package:enigma/src/features/chat_request/domain/usecases/accept_chat_request_usecase.dart';
import 'package:enigma/src/features/chat_request/domain/usecases/fetch_chat_request_usecase.dart';
import 'package:enigma/src/features/chat_request/domain/usecases/fetch_friends_usecase.dart';
import 'package:enigma/src/features/chat_request/domain/usecases/fetch_pending_request_usecase.dart';
import 'package:enigma/src/features/chat_request/domain/usecases/remove_friend_usecase.dart';
import 'package:enigma/src/features/chat_request/domain/usecases/send_chat_request_usecase.dart';
import 'package:enigma/src/features/profile/data/repository/profile_repository_impl.dart';
import 'package:enigma/src/features/profile/domain/usecases/create_profile_usecase.dart';
import 'package:enigma/src/features/profile/domain/usecases/delete_profile_usecase.dart';
import 'package:enigma/src/features/profile/domain/usecases/read_all_people_usecase.dart';
import 'package:enigma/src/features/profile/domain/usecases/read_all_profile_usecase.dart';
import 'package:enigma/src/features/profile/domain/usecases/read_profile_usecase.dart';
import 'package:enigma/src/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:enigma/src/features/story/data/repository/story_repository_impl.dart';
import 'package:enigma/src/features/story/domain/usecase/add_story_usecase.dart';
import 'package:enigma/src/features/story/domain/usecase/get_stories_usecase.dart';
import 'package:enigma/src/shared/data/repository/fcm_repository_impl.dart';
import 'package:enigma/src/shared/data/repository/media_repository_impl.dart';
import 'package:enigma/src/shared/domain/use_cases/profile_picture_usecase.dart';
import 'package:enigma/src/shared/domain/use_cases/send_push_message_usecase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/domain/usecases/change_email_usecase.dart';

final sl = GetIt.I;

Future<void> setupService() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  sl.registerSingletonAsync<SharedPreferenceManager>(() async {
    final SharedPreferenceManager sharedPreferenceManager = SharedPreferenceManager();
    await sharedPreferenceManager.init();
    return sharedPreferenceManager;
  });

  sl.registerSingletonAsync<SembastDbConfig>(() async {
    final sembastDbConfig = SembastDbConfig();
    await sembastDbConfig.init();
    return sembastDbConfig;
  });
  sl.registerSingleton<AuthRepositoryImpl>(AuthRepositoryImpl());
  sl.registerSingleton<ChangePasswordUseCase>(ChangePasswordUseCase());
  sl.registerSingleton<ForgotPasswordUseCase>(ForgotPasswordUseCase());
  sl.registerSingleton<LoginUseCase>(LoginUseCase());
  sl.registerSingleton<LogoutUseCase>(LogoutUseCase());
  sl.registerSingleton<SignupUseCase>(SignupUseCase());
  sl.registerSingleton<ChangeEmailUseCase>(ChangeEmailUseCase());

  sl.registerSingleton<ProfileRepositoryImpl>(ProfileRepositoryImpl());
  sl.registerSingleton<CreateProfileUseCase>(CreateProfileUseCase());
  sl.registerSingleton<ReadProfileUseCase>(ReadProfileUseCase());
  sl.registerSingleton<ReadAllProfileUseCase>(ReadAllProfileUseCase());

  sl.registerSingleton<ReadAllPeopleUseCase>(ReadAllPeopleUseCase());

  sl.registerSingleton<UpdateProfileUseCase>(UpdateProfileUseCase());
  sl.registerSingleton<DeleteProfileUseCase>(DeleteProfileUseCase());

  sl.registerSingleton<MediaRepositoryImpl>(MediaRepositoryImpl());
  sl.registerSingleton<ImageMediaUsecase>(ImageMediaUsecase());

  sl.registerSingleton<ChatRepositoryImpl>(ChatRepositoryImpl());
  sl.registerSingleton<AddChatUsecase>(AddChatUsecase());
  sl.registerSingleton<GetChatUsecase>(GetChatUsecase());

  sl.registerSingleton<ChatRequestRepositoryImpl>(ChatRequestRepositoryImpl());
  sl.registerSingleton<SendChatRequestUseCase>(SendChatRequestUseCase());
  sl.registerSingleton<FetchPendingRequestUseCase>(FetchPendingRequestUseCase());
  sl.registerSingleton<FetchChatRequestUseCase>(FetchChatRequestUseCase());
  sl.registerSingleton<AcceptChatRequestUseCase>(AcceptChatRequestUseCase());
  sl.registerSingleton<FetchFriendsUseCase>(FetchFriendsUseCase());
  sl.registerSingleton<RemoveFriendUseCase>(RemoveFriendUseCase());

  sl.registerSingleton<StoryRepositoryImpl>(StoryRepositoryImpl());
  sl.registerSingleton<AddStoryUseCase>(AddStoryUseCase());
  sl.registerSingleton<GetStoriesUseCase>(GetStoriesUseCase());

  LocalNotificationHandler();
  PushNotificationHandler();

  sl.registerSingleton<FCMRepositoryImpl>(FCMRepositoryImpl());
  sl.registerSingleton<SendPushMessageUsecase>(SendPushMessageUsecase());

  await sl.allReady();
}
