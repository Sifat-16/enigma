import 'package:enigma/src/core/network/remote/firebase/firebase_handler.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/features/chat/domain/entity/chat_entity.dart';
import 'package:enigma/src/features/chat/presentation/components/chat_screen_bottom_bar.dart';
import 'package:enigma/src/features/chat/presentation/components/chat_ui.dart';
import 'package:enigma/src/features/chat/presentation/view-model/chat_controller.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/features/profile/presentation/view/profile_screen.dart';
import 'package:enigma/src/features/voice_call/presentation/view/call_screen.dart';
import 'package:enigma/src/shared/widgets/circular_display_picture.dart';
import 'package:enigma/src/shared/widgets/shared_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  ChatScreen({super.key, required this.profileEntity});

  static const String route = "/chat";
  ProfileEntity profileEntity;

  static setRoute() => "/chat";

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final String userUid = FirebaseHandler.auth.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    //ProfileGeneric profileController = ref.watch(profileProvider);
    final ProfileEntity profileEntity = widget.profileEntity;
    return Scaffold(
        appBar: SharedAppbar(
          titleSpacing: -context.width * 0.04,
          leadingWidget: InkWell(
            onTap: () {
              ref.read(goRouterProvider).pop();
            },
            child: const Icon(
              Icons.arrow_back_outlined,
              size: 25,
            ),
          ),
          title: InkWell(
            onTap: () {
              ref
                  .read(goRouterProvider)
                  .push(ProfileScreen.setRoute(profileEntity: profileEntity));
            },
            child: ListTile(
              leading: CircularDisplayPicture(
                radius: 23,
                imageURL: profileEntity.avatarUrl ?? null,
              ),
              title: Text(
                profileEntity.name ?? "",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: Text(
                (profileEntity.isActive ?? false) ? "Active Now" : "",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          trailingWidgets: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CallScreen()));
              },
              child: Container(
                width: context.width * .1,
                height: context.width * .1,
                margin: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.call,
                  size: 25,
                ),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<Stream<List<ChatEntity>>>(
                  future: ref.read(chatProvider.notifier).getChat(
                        myUid: userUid,
                        friendUid: profileEntity.uid ?? "",
                      ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return StreamBuilder<List<ChatEntity>>(
                        stream: snapshot.data,
                        builder: (context, chatShot) {
                          // debug("From Chat Screen ${chatShot.data}");
                          if (chatShot.hasData) {
                            return ChatUI(chat: chatShot.data ?? []);
                          } else {
                            return const Center(
                                child: Text('No messages found'));
                          }

                          // if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          //   return const Center(
                          //       child: Text('No messages found'));
                          // } else {
                          //   return ChatUI(chat: snapshot.data!);
                          // }
                        },
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
            ChatScreenBottomBar(
              sender: userUid,
              receiver: profileEntity.uid ?? "",
            ),
            // ChatUI(textMessage: textMessage)
          ],
        ));
  }
}
