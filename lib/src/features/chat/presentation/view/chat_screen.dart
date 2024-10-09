import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/features/chat/domain/entity/chat_entity.dart';
import 'package:enigma/src/features/chat/presentation/components/chat_screen_bottom_bar.dart';
import 'package:enigma/src/features/chat/presentation/components/chat_ui.dart';
import 'package:enigma/src/features/chat/presentation/view-model/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  static const String route = "/chat";

  static get getRoute => '/chat';

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // final chatController = ref.watch(chatProvider);
    return Scaffold(
        appBar: AppBar(
          titleSpacing: -context.width * 0.04,
          title: ListTile(
            leading: CircleAvatar(
              radius: context.width * 0.05,
              backgroundColor: Colors.red,
            ),
            title: Text(
              "Text Flinders",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle: Text(
              "Active Now",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.call_outlined,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.video_camera_front_outlined),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder<Stream<List<ChatEntity>>>(
                  future: ref.read(chatProvider.notifier).getChat(
                        myUid: "SjKB4wFCutQyMOmrJUhXlX3eo5l1",
                        friendUid: "Y51bMMMKXAT1AQs0vPutTfVCkTB2",
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

            const ChatScreenBottomBar(),

            // ChatUI(textMessage: textMessage)
          ],
        ));
  }
}