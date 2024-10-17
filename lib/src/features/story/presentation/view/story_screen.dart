import 'dart:async';

import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/story/domain/entity/story_entity.dart';
import 'package:enigma/src/features/story/domain/entity/user_story_entity.dart';
import 'package:enigma/src/features/story/presentation/view_model/story_controller.dart';
import 'package:enigma/src/features/story/presentation/view_model/story_generic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryScreen extends ConsumerStatefulWidget {
  StoryScreen({super.key, required this.data});
  static const route = "/story/:index";
  String data;
  static setRoute(int index) => "/story/${index.toString()}";

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen> {
  final PageController _pageController = PageController();
  int _currentStoryIndex = 0;
  List<UserStoryEntity> _stories = [];
  Timer? _timer;
  final ValueNotifier<int> _currentStory = ValueNotifier(0);
  final ValueNotifier<double> _progress = ValueNotifier(0.0);
  final ValueNotifier<bool> _isPaused = ValueNotifier(false);

  @override
  void initState() {
    _currentStoryIndex = int.tryParse(widget.data) ?? 0;
    debug(_currentStoryIndex);

    if (_currentStoryIndex == -1) {
      _currentStoryIndex = 0;
      _stories.add((ref.read(storyProvider).myStory ?? UserStoryEntity()));
      _startProgress(_stories[_currentStory.value].storyList ?? []);
    } else {
      _stories = ref.read(storyProvider).friendsStories;
      _startProgress(ref
              .read(storyProvider)
              .friendsStories[_currentStoryIndex]
              .storyList ??
          []);
    }

    super.initState();
  }

  void _startProgress(List<StoryEntity> storyList) {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isPaused.value) {
        _progress.value += 0.02;
      }
      if (_progress.value >= 1.0) {
        _goToNextStory(storyList);
      }
    });
  }

  void _goToNextFriendsStory(List<StoryEntity> storyList) {
    _timer?.cancel();
    if (_currentStoryIndex < _stories.length - 1) {
      _currentStoryIndex++;
      _progress.value = 0.0;
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      //_startProgress(_stories[_currentStoryIndex].storyList ?? []);
    } else {
      // Story ended

      ref.read(goRouterProvider).pop(); // Close popup
    }
  }

  void _goToNextStory(List<StoryEntity> storyList) {
    _timer?.cancel();
    if (_currentStory.value < storyList.length - 1) {
      _currentStory.value++;
      _progress.value = 0.0;
      _startProgress(storyList);
    } else {
      // Story ended
      _currentStory.value = 0;
      if (_currentStoryIndex < _stories.length - 1) {
        _goToNextFriendsStory(_stories[_currentStoryIndex + 1].storyList ?? []);
      }
      // Close popup
      else {
        if (mounted) {
          ref.read(goRouterProvider).pop();
        }
      }
    }
  }

  void _goToPreviousFriendsStory(List<StoryEntity> storyList) {
    _timer?.cancel();
    if (_currentStoryIndex > 0) {
      _currentStoryIndex--;
      _progress.value = 0.0;
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      //_startProgress(storyList);
    }
  }

  void _goToPreviousStory(List<StoryEntity> storyList) {
    _timer?.cancel();
    if (_currentStory.value > 0) {
      _currentStory.value--;
      _progress.value = 0.0;
      _startProgress(storyList);
    } else {
      _currentStory.value = 0;
      if (_currentStoryIndex > 0) {
        _goToPreviousFriendsStory(
            _stories[_currentStoryIndex - 1].storyList ?? []);
      } else {
        _startProgress(storyList);
      }
    }
  }

  // void _pauseTimer() {
  //   _isPaused.value = true;
  // }
  //
  // void _resumeTimer() {
  //   _isPaused.value = false;
  // }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    StoryGeneric storyController = ref.watch(storyProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          if (details.globalPosition.dx <
              MediaQuery.of(context).size.width / 2) {
            _goToPreviousStory(_stories[_currentStoryIndex].storyList ?? []);
          } else {
            _goToNextStory(_stories[_currentStoryIndex].storyList ?? []);
          }
        },
        onVerticalDragEnd: (details) {
          // Check if the swipe was in the downward direction
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            // Velocity > 0 means a downward swipe
            ref.read(goRouterProvider).pop(); // Pop the current screen
          }
        },
        // onLongPress: _pauseTimer,
        // onLongPressEnd: (_) => _resumeTimer(),
        child: Stack(
          children: [
            // Story content
            PageView.builder(
              controller: _pageController,
              itemCount: storyController.friendsStories.length,
              onPageChanged: (index) {
                _currentStoryIndex = index;
                _progress.value = 0.0;
                _startProgress(_stories[_currentStoryIndex].storyList ?? []);
              },
              itemBuilder: (context, index) {
                index = _currentStoryIndex;

                return ValueListenableBuilder(
                  builder: (context, value, child) {
                    return Stack(children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(top: 70),
                          width: double.infinity,
                          child: Text(
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            _stories[index].name ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color:
                                        Theme.of(context).secondaryHeaderColor),
                          ),
                        ),
                      ),
                      Image.network(
                        _stories[index].storyList?[value].mediaLink ??
                            "https://fastly.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI",
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20)),
                          child: SingleChildScrollView(
                            child: Text(
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              _stories[index].storyList?[value].content ?? "",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ]);
                  },
                  valueListenable: _currentStory,
                );
              },
            ),
            // Progress bar
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: ValueListenableBuilder(
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white38,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  );
                },
                valueListenable: _progress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
