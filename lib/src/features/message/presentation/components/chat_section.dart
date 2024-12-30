import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/features/chat/domain/entity/chat_entity.dart';
import 'package:enigma/src/features/chat/presentation/view/chat_screen.dart';
import 'package:enigma/src/features/chat_request/presentation/view_model/chat_request_controller.dart';
import 'package:enigma/src/features/chat_request/presentation/view_model/chat_request_generic.dart';
import 'package:enigma/src/features/profile/presentation/view_model/controller/profile_controller.dart';
import 'package:enigma/src/features/profile/presentation/view_model/generic/profile_generic.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/widgets/circular_display_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
class ChatSection extends ConsumerStatefulWidget {
  const ChatSection({super.key});

  @override
  ConsumerState<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends ConsumerState<ChatSection> {
  SharedPreferenceManager sharedPreferenceManager = sl.get<SharedPreferenceManager>();

  @override
  Widget build(BuildContext context) {
    final ChatRequestGeneric chatRequestController = ref.watch(chatRequestProvider);
    final ProfileGeneric profileController = ref.watch(profileProvider);
    return profileController.isLoading ? const Center(child: CircularProgressIndicator()) : ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return InkWell(
            onTap: () {
              ref
                  .read(goRouterProvider)
                  .push(ChatScreen.setRoute(), extra: profileController.listOfFriends[index]);
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
                                imageURL: profileController.listOfFriends[index].avatarUrl ?? null,
                              ),
                              Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Icon(
                                    Icons.circle,
                                    color: (profileController.listOfFriends[index].isActive ?? false)
                                        ? Colors.green
                                        : Colors.transparent,
                                    size: 15,
                                  ))
                            ],
                          ),
                        ),
                        // FutureBuilder(
                        //   future: ref
                        //       .read(messageProvider.notifier)
                        //       .getAllFriendsLastMessage(friends: profileController.listOfFriends, myID: "myID"),
                        //   builder: (context, snapshot) {
                        //     return Text("${snapshot.hasData}");
                        //   },
                        // )
                        Flexible(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profileController.listOfFriends[index].name ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                if (profileController.listOfFriends[index].lastMessage?.type == MediaType.text.name)
                                  Text("${profileController.listOfFriends[index].lastMessage?.content}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.labelSmall)
                                else
                                  Text(
                                      "${profileController.listOfFriends[index].lastMessage?.type!.toUpperCase()} MESSAGE",
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
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          DateFormat.jm().format(
                            profileController.listOfFriends[index].lastMessage!.timestamp!,
                          ),
                        ),
                        Text(
                          DateFormat.yMd().format(
                            profileController.listOfFriends[index].lastMessage!.timestamp!,
                          ),
                        )
                        // Text(
                        //   (profileController.listOfFriends[index].isActive ?? false)
                        //       ? ""
                        //       : getLastSeen(
                        //           profileController.listOfFriends[index].lastSeen ?? DateTime.now()),
                        //   style: Theme.of(context).textTheme.labelSmall,
                        // )
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
            ));
      },
      itemCount: profileController.listOfFriends.length,
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(
          height: 5,
        );
      },
    );;
  }
}
