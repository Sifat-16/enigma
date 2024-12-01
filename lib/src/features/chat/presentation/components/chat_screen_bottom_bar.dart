import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:enigma/src/core/global/global_variables.dart';
import 'package:enigma/src/core/network/remote/firebase/firebase_storage_directory_name.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/chat_utils/chat_utils.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/chat/domain/entity/chat_entity.dart';
import 'package:enigma/src/features/chat/presentation/components/media_preview_screen.dart';
import 'package:enigma/src/features/chat/presentation/components/voice_message_view.dart';
import 'package:enigma/src/features/chat/presentation/view-model/chat_controller.dart';
import 'package:enigma/src/features/chat_request/presentation/view_model/chat_request_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class ChatScreenBottomBar extends ConsumerStatefulWidget {
  const ChatScreenBottomBar({
    super.key,
    required this.sender,
    required this.receiver,
  });

  final String sender;
  final String receiver;

  @override
  ConsumerState<ChatScreenBottomBar> createState() => _ChatScreenBottomBarState();
}

class _ChatScreenBottomBarState extends ConsumerState<ChatScreenBottomBar> {
  final ValueNotifier<TextEditingController> messageTextController = ValueNotifier(TextEditingController());
  final ValueNotifier<File?> imageFile = ValueNotifier(null);
  final ValueNotifier<File?> audioFile = ValueNotifier(null);
  final ValueNotifier<bool> isRecording = ValueNotifier(false);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  String? url;

  final record = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  String? path;
  Duration? audioDuration;

  void _showOptions(BuildContext context) {
    showBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            filesOption(
              title: "Camera",
              onTap: () {},
              icon: Icons.camera,
            ),
            filesOption(
              title: "Documents",
              subtitle: "Share your files",
              onTap: () async {},
              icon: Icons.insert_drive_file_sharp,
            ),
            filesOption(
              title: "Create a Poll",
              subtitle: "Create a poll for any query",
              onTap: () {},
              icon: Icons.poll_outlined,
            ),
            filesOption(
              title: "Media",
              subtitle: "Share photos and videos",
              onTap: () async {
                imageFile.value = await ChatUtils.pickImage(
                  imageSource: ImageSource.gallery,
                );
                container.read(goRouterProvider).pop();
                messageTextController.value.text = await ChatUtils.textRecognition(imageFile.value!);
              },
              icon: Icons.perm_media_outlined,
            ),
            filesOption(
              title: "Contract",
              subtitle: "Share your contacts",
              onTap: () {},
              icon: Icons.person,
            ),
            filesOption(
              title: "Location",
              subtitle: "Share your location",
              onTap: () {},
              icon: Icons.location_on_outlined,
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final chatController = ref.watch(chatProvider);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: imageFile,
              builder: (context, value, child) {
                if (value != null) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      MediaPreviewScreen(file: value),
                      Container(
                        margin: const EdgeInsets.all(10),
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          onPressed: () {
                            imageFile.value = null;
                          },
                          icon: const Icon(
                            Icons.delete,
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            ValueListenableBuilder(
              valueListenable: isRecording,
              builder: (context, value, child) {
                if (value) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mic),
                      Text(
                        "Say Something",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            ValueListenableBuilder(
              valueListenable: audioFile,
              builder: (context, value, child) {
                if (value != null) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      VoiceMessageViewWidget(
                        url: audioFile.value?.path ?? "",
                        isFile: true,
                      ),
                      IconButton(
                        onPressed: () async {
                          url = await ref.read(chatProvider.notifier).addImageMedia(
                                file: audioFile.value!,
                                directory: FirebaseStorageDirectoryName.CHAT_MEDIA_DIRECTORY,
                                fileName: const Uuid().v4(),
                              );
                          ChatEntity chatEntity = ChatEntity(
                            id: const Uuid().v4(),
                            type: MediaType.voice,
                            mediaLink: url,
                            timestamp: DateTime.now(),
                            sender: widget.sender,
                            receiver: widget.receiver,
                          );
                          debug(widget.sender);
                          debug(widget.receiver);
                          audioFile.value = null;
                          ref.read(chatProvider.notifier).addChat(chatEntity);

                        },
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showOptions(context),
                  child: CircleAvatar(
                    //radius: context.width * 0.05,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    child: Icon(
                      Icons.attach_file,
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: messageTextController.value,
                    maxLines: null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                      hintText: "Write your message",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      suffixIcon: GestureDetector(
                        child: CircleAvatar(
                          //radius: context.width * 0.05,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.file_copy_outlined,
                            color: Theme.of(context).canvasColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: messageTextController.value,
                  builder: (context, value, child) {
                    if (value.text.trim().isEmpty && imageFile.value == null) {
                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              imageFile.value = await ChatUtils.pickImage(
                                imageSource: ImageSource.camera,
                              );
                              messageTextController.value.text =
                                  await ChatUtils.textRecognition(imageFile.value!);
                            },
                            child: CircleAvatar(
                              //radius: context.width * 0.05,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: Theme.of(context).canvasColor,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onLongPressStart: (details) {
                              audioFile.value = null;
                              isRecording.value = true;
                              ChatUtils.startRecord(record);
                            },
                            onLongPressEnd: (details) async {
                              path = await record.stop();
                              if (path != null) {
                                audioFile.value = File(path!);
                              }
                              isRecording.value = false;
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.mic_none_outlined,
                                color: Theme.of(context).canvasColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return GestureDetector(
                        onTap: () async {
                          Uuid uuid = const Uuid();
                          if (imageFile.value != null) {
                            url = await ref.read(chatProvider.notifier).addImageMedia(
                                  file: imageFile.value!,
                                  directory: FirebaseStorageDirectoryName.CHAT_MEDIA_DIRECTORY,
                                  fileName: imageFile.value!.path.split("/").last,
                                );
                          }
                          if (messageTextController.value.text.trim().isNotEmpty || imageFile.value != null) {
                            ChatEntity chatEntity = ChatEntity(
                              id: uuid.v4(),
                              content: messageTextController.value.text.trim(),
                              type: url != null ? MediaType.image : MediaType.text,
                              mediaLink: url,
                              timestamp: DateTime.now(),
                              receiver: widget.receiver,
                              sender: widget.sender,
                            );
                            imageFile.value = null;
                            messageTextController.value.clear();
                            ref.read(chatProvider.notifier).addChat(chatEntity);
                            // debug("Success message");
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.send,
                            color: Theme.of(context).canvasColor,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget filesOption({
  required String title,
  String subtitle = "",
  required Function() onTap,
  required IconData icon,
}) =>
    ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: Icon(icon),
        // backgroundColor: primary.withOpacity(0.5),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
