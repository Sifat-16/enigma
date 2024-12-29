import 'dart:io';

import 'package:enigma/src/core/database/local/shared_preference/shared_preference_keys.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/chat_utils/chat_utils.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/chat/presentation/components/chat_screen_bottom_bar.dart';
import 'package:enigma/src/features/story/presentation/view/story_preview_screen.dart';
import 'package:enigma/src/features/story/presentation/view/story_screen.dart';
import 'package:enigma/src/features/story/presentation/view_model/story_controller.dart';
import 'package:enigma/src/features/story/presentation/view_model/story_generic.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/widgets/circular_display_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
class StorySection extends ConsumerStatefulWidget {
  const StorySection({super.key});

  @override
  ConsumerState<StorySection> createState() => _StorySectionState();
}

class _StorySectionState extends ConsumerState<StorySection> {
  SharedPreferenceManager sharedPreferenceManager = sl.get<SharedPreferenceManager>();

  void _showOptions(BuildContext context, bool showViewStory) {
    File? imageFile;
    showBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showViewStory)
              filesOption(
                title: "My Story",
                subtitle: "View my story",
                onTap: () async {
                  ref.read(goRouterProvider).push(StoryScreen.setRoute(-1));
                },
                icon: Icons.history,
              ),
            filesOption(
              title: "Camera",
              subtitle: "Take a picture",
              onTap: () async {
                imageFile = await ChatUtils.pickImage(
                  imageSource: ImageSource.camera,
                );

                if (imageFile != null) {
                  ref.read(goRouterProvider).push(StoryPreviewScreen.route, extra: imageFile);
                }

                debug(imageFile?.path ?? "");
              },
              icon: Icons.camera,
            ),
            filesOption(
              title: "Gallery",
              subtitle: "Select a picture",
              onTap: () async {
                imageFile = await ChatUtils.pickImage(
                  imageSource: ImageSource.gallery,
                );

                if (imageFile != null) {
                  ref.read(goRouterProvider).push(StoryPreviewScreen.route, extra: imageFile);
                }

                debug(imageFile?.path ?? "");
              },
              icon: Icons.image,
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final StoryGeneric storyController = ref.watch(storyProvider);
    return Container(
      padding: const EdgeInsets.only(left: 15),
      //color: Colors.red,
      height: context.height * .13,
      width: double.infinity,
      child: ListView.builder(
        itemBuilder: (context, index) {
          String uid = sharedPreferenceManager.getValue(key: SharedPreferenceKeys.USER_UID);
          if (index == 0) {
            if ((storyController.myStory?.storyList ?? []).isEmpty) {
              return InkWell(
                onTap: () {
                  _showOptions(context, false);
                },
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircularDisplayPicture(
                              imageURL: null,
                              radius: 25,
                            ),
                            Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black, borderRadius: BorderRadius.circular(500)),
                                  child: const Icon(
                                    Icons.add_circle_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "My Story",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          //style: customLightTheme.primaryTextTheme.labelLarge,
                        )
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return InkWell(
                onTap: () {
                  _showOptions(context, true);
                },
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        CircularDisplayPicture(
                          imageURL: null,
                          radius: 25,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          storyController.myStory?.name ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            return InkWell(
              onTap: () {
                // can send index,
                ref.read(goRouterProvider).push(StoryScreen.setRoute(index - 1));
              },
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: SizedBox(
                  width: 70,
                  child: Column(
                    children: [
                      CircularDisplayPicture(
                        imageURL: null,
                        radius: 25,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        storyController.friendsStories[index - 1].name ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        //style: customLightTheme.primaryTextTheme.labelLarge,
                      )
                    ],
                  ),
                ),
              ),
            );
          }
        },
        itemCount: storyController.friendsStories.length + 1,
        scrollDirection: Axis.horizontal,
      ),
    );;
  }
}


