import 'package:cached_network_image/cached_network_image.dart';
import 'package:enigma/src/core/network/remote/firebase/firebase_handler.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/features/chat/domain/entity/chat_entity.dart';
import 'package:enigma/src/features/chat/presentation/components/voice_message_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatUI extends StatelessWidget {
  ChatUI({super.key, required this.chat});

  bool isSameDay = false;
  final List<ChatEntity> chat;

  @override
  Widget build(BuildContext context) {
    // print(context.width);
    // print(chat.length);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        reverse: true,
        itemCount: chat.length,
        itemBuilder: (context, index) {
          if (index > 0) {
            isSameDay = DateFormat.yMEd().format(chat[index].timestamp!) ==
                DateFormat.yMEd().format(chat[index - 1].timestamp!);
          }

          chat.sort((b, a) =>
              DateTime.parse(a.timestamp.toString()).compareTo(DateTime.parse(b.timestamp.toString())));
          if (chat[index].sender == FirebaseHandler.auth.currentUser!.uid) {
            return Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(10),
                margin: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: context.width * 0.2,
                ),
                decoration: BoxDecoration(
                  color: chat[index].type == MediaType.voice
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (chat[index].content != null && chat[index].content != "")
                      Text(
                        "${chat[index].content}",
                        softWrap: true,
                        textAlign: TextAlign.justify,
                      ),
                    if (chat[index].mediaLink != null)
                      if (chat[index].type == MediaType.image)
                        GestureDetector(
                          onTap: () {},
                          child: CachedNetworkImage(
                            imageUrl: chat[index].mediaLink!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.image),
                          ),
                        )
                      else if (chat[index].type == MediaType.video)
                        const Text("There is video. Will add later on")
                      else if (chat[index].type == MediaType.voice)
                        VoiceMessageViewWidget(
                          url: chat[index].mediaLink ?? "",
                          isFile: false,
                        )
                      else if (chat[index].type == MediaType.file)
                        const Text("There is file. Will add later on"),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        chat[index].timestamp.toString().substring(10, 16),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: 10,
                  right: context.width * 0.2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                // width: context.width * .8,
                decoration: BoxDecoration(
                  color: chat[index].type == MediaType.voice
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chat[index].content != null)
                      Text(
                        "${chat[index].content}",
                        softWrap: true,
                        textAlign: TextAlign.justify,
                      ),
                    if (chat[index].mediaLink != null)
                      if (chat[index].type == MediaType.image)
                        GestureDetector(
                          onTap: () {},
                          child: CachedNetworkImage(
                            imageUrl: chat[index].mediaLink!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.image),
                          ),
                        )
                      else if (chat[index].type == MediaType.video)
                        const Text("There is video. Will add later on")
                      else if (chat[index].type == MediaType.voice)
                        VoiceMessageViewWidget(
                          url: chat[index].mediaLink ?? "",
                          isFile: false,
                        )
                      else if (chat[index].type == MediaType.file)
                        const Text("There is file. Will add later on"),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        chat[index].timestamp.toString().substring(10, 16),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// double getTextWidth(String text) {
//   // Create a TextSpan with the text and style
//   TextSpan textSpan = TextSpan(text: text);
//   print(text);
//   // Create a TextPainter with the TextSpan
//   TextPainter textPainter = TextPainter(
//     text: textSpan,
//     textDirection: TextDirection.ltr,
//   );
//
//   // Layout the text to calculate its size
//   textPainter.layout();
//   print(textPainter.size.width);
//   // Return the width of the text
//   return textPainter.size.width;
// }

// class ChatUI extends StatelessWidget {
//   ChatUI({super.key}) {
//     // Add dummy messages
//     _addDummyMessages();
//   }
//
//   final ValueNotifier<TextEditingController> messageTextController =
//       ValueNotifier(TextEditingController());
//   final ValueNotifier<List<types.Message>> _messages = ValueNotifier([]);
//   final _user = const types.User(id: "ABC");
//
//   void _handleSendPressed(types.PartialText message) {
//     final textMessage = types.TextMessage(
//       author: _user,
//       createdAt: DateTime.now().millisecondsSinceEpoch,
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       text: message.text,
//     );
//
//     _addMessage(textMessage);
//   }
//
//   void _addMessage(types.Message message) {
//     print("Adding message: $message");
//     final updatedMessages = List<types.Message>.from(_messages.value)
//       ..insert(0, message);
//     _messages.value = updatedMessages; // Update the ValueNotifier's value
//   }
//
//   void _addDummyMessages() {
//     final dummyMessages = [
//       types.TextMessage(
//         author: _user,
//         createdAt: DateTime.now()
//             .subtract(Duration(minutes: 10))
//             .millisecondsSinceEpoch,
//         id: "1",
//         text: "Hello! This is a dummy message.",
//       ),
//       types.TextMessage(
//         author: _user,
//         createdAt: DateTime.now()
//             .subtract(Duration(minutes: 8))
//             .millisecondsSinceEpoch,
//         id: "2",
//         text: "Here's another dummy message for testing.",
//       ),
//       types.TextMessage(
//         author: const types.User(id: "XYZ"),
//         createdAt: DateTime.now()
//             .subtract(Duration(minutes: 5))
//             .millisecondsSinceEpoch,
//         id: "3",
//         text: "Hi! I'm a different user.",
//       ),
//       types.CustomMessage(
//         author: _user,
//         createdAt: DateTime.now()
//             .subtract(Duration(minutes: 3))
//             .millisecondsSinceEpoch,
//         id: "4",
//         metadata: const {
//           'type': 'audio',
//           'url':
//               'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
//         },
//       ),
//     ];
//
//     _messages.value = List<types.Message>.from(_messages.value)
//       ..addAll(dummyMessages);
//   }
//
//   Widget _audioMessageBuilder(types.CustomMessage message,
//       {required int messageWidth}) {
//     final audioUrl = message.metadata?['url'] as String?;
//     if (audioUrl == null) {
//       return const SizedBox.shrink();
//     }
//
//     final player = AudioPlayer();
//
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       width: messageWidth.toDouble(),
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.play_arrow),
//             onPressed: () {
//               player.play(UrlSource(audioUrl));
//               // player.play(Uri.parse(audioUrl));
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.stop),
//             onPressed: () {
//               player.stop();
//             },
//           ),
//           Expanded(
//             child: Text(
//               'Audio Message',
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showOptions(BuildContext context) {
//     showBottomSheet(
//       context: context,
//       builder: (context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             filesOption(
//               title: "Camera",
//               onTap: () {},
//               icon: Icons.camera,
//             ),
//             filesOption(
//               title: "Documents",
//               subtitle: "Share your files",
//               onTap: () {},
//               icon: Icons.insert_drive_file_sharp,
//             ),
//             filesOption(
//               title: "Create a Poll",
//               subtitle: "Create a poll for any query",
//               onTap: () {},
//               icon: Icons.poll_outlined,
//             ),
//             filesOption(
//               title: "Media",
//               subtitle: "Share photos and videos",
//               onTap: () {},
//               icon: Icons.perm_media_outlined,
//             ),
//             filesOption(
//               title: "Contract",
//               subtitle: "Share your contacts",
//               onTap: () {},
//               icon: Icons.person,
//             ),
//             filesOption(
//               title: "Location",
//               subtitle: "Share your location",
//               onTap: () {},
//               icon: Icons.location_on_outlined,
//             )
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: _messages,
//       builder: (context, value, child) {
//         return Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Chat(
//             messages: value,
//             onSendPressed: _handleSendPressed,
//             user: _user,
//             showUserAvatars: true,
//             showUserNames: true,
//             // fileMessageBuilder: () {},
//             theme: DefaultChatTheme(
//               backgroundColor: Theme.of(context).colorScheme.surface,
//             ),
//             customBottomWidget: Align(
//               alignment: Alignment.bottomCenter,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       onPressed: () => _showOptions(context),
//                       icon: Icon(
//                         Icons.attach_file,
//                         color: Theme.of(context).primaryColor,
//                       ),
//                     ),
//                     Expanded(
//                       child: TextFormField(
//                         controller: messageTextController.value,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Theme.of(context)
//                               .colorScheme
//                               .secondary
//                               .withOpacity(0.3),
//                           hintText: "Write your message",
//                           border: OutlineInputBorder(
//                             borderSide: BorderSide.none,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           suffixIcon: IconButton(
//                             onPressed: () {},
//                             icon: Icon(
//                               Icons.file_copy_outlined,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     ValueListenableBuilder(
//                       valueListenable: messageTextController.value,
//                       builder: (context, value, child) {
//                         if (value.text.trim().isEmpty) {
//                           return Row(
//                             children: [
//                               IconButton(
//                                 onPressed: () {},
//                                 icon: Icon(
//                                   Icons.camera_alt_outlined,
//                                   color: Theme.of(context).colorScheme.primary,
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () {},
//                                 icon: Icon(
//                                   Icons.mic_none_outlined,
//                                   color: Theme.of(context).colorScheme.primary,
//                                 ),
//                               )
//                             ],
//                           );
//                         } else {
//                           return IconButton(
//                             onPressed: () {
//                               _handleSendPressed(
//                                 types.PartialText(
//                                   text: messageTextController.value.text,
//                                 ),
//                               );
//                               messageTextController.value.clear();
//                             },
//                             icon: Icon(
//                               Icons.send,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
