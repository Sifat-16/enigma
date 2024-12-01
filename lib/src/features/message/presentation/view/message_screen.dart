import 'dart:io';

import 'package:enigma/src/core/database/local/shared_preference/shared_preference_keys.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/notification/push_notification/push_notification_handler.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/chat_utils/chat_utils.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/chat/presentation/components/chat_screen_bottom_bar.dart';
import 'package:enigma/src/features/chat/presentation/view/chat_screen.dart';
import 'package:enigma/src/features/chat_request/presentation/view_model/chat_request_controller.dart';
import 'package:enigma/src/features/chat_request/presentation/view_model/chat_request_generic.dart';
import 'package:enigma/src/features/message/domain/entity/message_entity.dart';
import 'package:enigma/src/features/profile/presentation/view/settings_screen.dart';
import 'package:enigma/src/features/profile/presentation/view_model/controller/profile_controller.dart';
import 'package:enigma/src/features/profile/presentation/view_model/generic/profile_generic.dart';
import 'package:enigma/src/features/story/presentation/view/story_preview_screen.dart';
import 'package:enigma/src/features/story/presentation/view/story_screen.dart';
import 'package:enigma/src/features/story/presentation/view_model/story_controller.dart';
import 'package:enigma/src/features/story/presentation/view_model/story_generic.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/widgets/circular_display_picture.dart';
import 'package:enigma/src/shared/widgets/shared_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class MessageScreen extends ConsumerStatefulWidget {
  MessageScreen({
    super.key,
  });
  MessageEntity? messageEntity;
  static const route = "/message";
  static setRoute() => "/message";

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  File? imageFile;
  SharedPreferenceManager sharedPreferenceManager =
      sl.get<SharedPreferenceManager>();
  List<String> storyNames = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((t) async {
      init();
    });
    PushNotificationHandler.setupInteractedMessage();
    super.initState();
  }

  init() async {
    await ref.read(profileProvider.notifier).readProfile(
        sharedPreferenceManager.getValue(key: SharedPreferenceKeys.USER_UID));
    await ref.read(chatRequestProvider.notifier).fetchFriends();
    await ref.read(storyProvider.notifier).getStories(
        uid: sharedPreferenceManager.getValue(
            key: SharedPreferenceKeys.USER_UID),
        isMyStory: true);
    await ref.read(profileProvider.notifier).readAllProfile();
  }

  @override
  Widget build(BuildContext context) {
    StoryGeneric storyController = ref.watch(storyProvider);
    return Scaffold(
        //backgroundColor: Theme.of(context).colorScheme.secondary,
        appBar: SharedAppbar(
            title: const Text("Home"),
            // leadingWidget: GestureDetector(
            //   onTap: () {},
            //   child: Container(
            //     height: context.height * .05,
            //     width: context.width * .05,
            //     margin: const EdgeInsets.all(8),
            //     child: GestureDetector(
            //       onTap: () {},
            //       child: const Icon(
            //         Icons.search,
            //         size: 25,
            //       ),
            //     ),
            //   ),
            // ),
            trailingWidgets: [
              GestureDetector(
                onTap: () {
                  ref.read(goRouterProvider).go(SettingsScreen.route);
                },
                child: Container(
                  height: context.height * .15,
                  width: context.width * .137,
                  padding: const EdgeInsets.all(8),
                  child: CircularDisplayPicture(
                    radius: 30,
                    imageURL:
                        ref.read(profileProvider).profileEntity?.avatarUrl ??
                            "",
                  ),
                ),
              )
            ]),
        body: RefreshIndicator(
          onRefresh: () async {
            await init();
          },
          child: ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) => SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  buildStorySection(context, storyController),
                  buildChatSection(context)
                ],
              ),
            ),
          ),
        ));
  }

  String getLastSeen(DateTime lastSeen) {
    Duration difference = DateTime.now().difference(lastSeen);
    return "${difference.inMinutes.toString()} mins ago";
  }

  Widget buildChatSection(BuildContext context) {
    final ChatRequestGeneric chatRequestController =
        ref.watch(chatRequestProvider);
    final ProfileGeneric profileController = ref.watch(profileProvider);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            ref.read(goRouterProvider).push(ChatScreen.setRoute(),
                extra: profileController.listOfFriends[index]);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Stack(
                          children: [
                            CircularDisplayPicture(
                              radius: 23,
                              imageURL: profileController
                                      .listOfFriends[index].avatarUrl ??
                                  null,
                            ),
                            Positioned(
                                right: 0,
                                bottom: 0,
                                child: Icon(
                                  Icons.circle,
                                  color: (profileController
                                              .listOfFriends[index].isActive ??
                                          false)
                                      ? Colors.green
                                      : Colors.transparent,
                                  size: 15,
                                ))
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profileController.listOfFriends[index].name ??
                                    "",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text("How are you doing today?",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        (profileController.listOfFriends[index].isActive ??
                                false)
                            ? ""
                            : getLastSeen(profileController
                                    .listOfFriends[index].lastSeen ??
                                DateTime.now()),
                        style: Theme.of(context).textTheme.labelSmall,
                      )
                      //todo : add when message is fixed
                      // const CircleAvatar(
                      //   backgroundColor: Colors.green,
                      //   radius: 10,
                      //   child: Text(
                      //     "3",
                      //     style: TextStyle(fontSize: 10),
                      //   ),
                      // )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
      itemCount: profileController.listOfFriends.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: 5,
        );
      },
    );
  }

  void _showOptions(BuildContext context, bool showViewStory) {
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
                  ref
                      .read(goRouterProvider)
                      .push(StoryPreviewScreen.route, extra: imageFile);
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
                  ref
                      .read(goRouterProvider)
                      .push(StoryPreviewScreen.route, extra: imageFile);
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

  Widget buildStorySection(BuildContext context, StoryGeneric storyController) {
    return Container(
      padding: const EdgeInsets.only(left: 15),
      //color: Colors.red,
      height: context.height * .13,
      width: double.infinity,
      child: ListView.builder(
        itemBuilder: (context, index) {
          String uid = sharedPreferenceManager.getValue(
              key: SharedPreferenceKeys.USER_UID);
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
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(500)),
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
                ref
                    .read(goRouterProvider)
                    .push(StoryScreen.setRoute(index - 1));
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
    );
  }
}
