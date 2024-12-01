import 'package:bot_toast/bot_toast.dart';
import 'package:dartz/dartz.dart';
import 'package:enigma/src/core/network/responses/failure_response.dart';
import 'package:enigma/src/core/network/responses/success_response.dart';
import 'package:enigma/src/features/story/domain/dto/story_dto.dart';
import 'package:enigma/src/features/story/domain/entity/story_entity.dart';
import 'package:enigma/src/features/story/domain/entity/user_story_entity.dart';
import 'package:enigma/src/features/story/domain/usecase/add_story_usecase.dart';
import 'package:enigma/src/features/story/domain/usecase/get_stories_usecase.dart';
import 'package:enigma/src/features/story/presentation/view_model/story_generic.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storyProvider = StateNotifierProvider<StoryController, StoryGeneric>(
  (ref) => StoryController(ref),
);

class StoryController extends StateNotifier<StoryGeneric> {
  StoryController(this.ref) : super(StoryGeneric());
  Ref ref;

  AddStoryUseCase addStoryUseCase = sl.get<AddStoryUseCase>();
  GetStoriesUseCase getStoriesUseCase = sl.get<GetStoriesUseCase>();

  addStory(
      {required StoryEntity storyEntity,
      required UserStoryEntity userStoryEntity}) async {
    StoryDto params =
        StoryDto(userStoryEntity: userStoryEntity, storyEntity: storyEntity);
    Either<Failure, Success> response = await addStoryUseCase.call(params);
    response.fold((left) {
      BotToast.showText(text: left.message);
    }, (right) {
      BotToast.showText(text: right.message);
    });
  }

  getStories({required uid, isMyStory = false}) async {
    List<UserStoryEntity> stories =
        List<UserStoryEntity>.from(state.friendsStories);
    //List<UserStoryEntity> stories = [];
    UserStoryEntity myStory = UserStoryEntity();
    Either<Failure, UserStoryEntity> response =
        await getStoriesUseCase.call(uid);
    response.fold((left) {
      BotToast.showText(text: left.message);
    }, (right) {
      if (isMyStory) {
        if ((right.storyList ?? []).isNotEmpty || right.name != null) {
          myStory = right;
        }
        state = state.update(myStory: myStory);
      } else {
        if ((right.storyList ?? []).isNotEmpty) {
          int index = stories.indexWhere((story) => story.uid == right.uid);
          if (index != -1) {
            stories[index] = right; // Update with new values
          } else {
            stories.add(right);
          }
        }
        state = state.update(friendsStories: stories);
      }
    });
  }

  fetchAllFriendsStories(Set<String> friendsUids) async {
    for (String id in friendsUids) {
      await getStories(uid: id);
    }
  }
}
