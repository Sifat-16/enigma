import 'package:cached_network_image/cached_network_image.dart';
import 'package:enigma/src/core/network/remote/firebase/firebase_handler.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
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
            try {
              isSameDay = DateFormat.yMEd().format(chat[index].timestamp!) ==
                  DateFormat.yMEd().format(chat[index - 1].timestamp!);
              debug("IS SAME DAY: ${isSameDay}");
            } catch (e) {}
          }

          chat.sort(
            (b, a) =>
                DateTime.parse(a.timestamp.toString()).compareTo(DateTime.parse(b.timestamp.toString())),
          );
          if (chat[index].sender == FirebaseHandler.auth.currentUser!.uid) {
            return Column(
              children: [
                // if (!isSameDay)
                //   Center(
                //     child: Container(
                //       padding: const EdgeInsets.all(10),
                //       decoration: BoxDecoration(
                //           color: Theme.of(context).colorScheme.secondary,
                //           borderRadius: BorderRadius.circular(30)),
                //       child: Text(DateFormat.yMMMMEEEEd().format(chat[index].timestamp!)),
                //     ),
                //   ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IntrinsicWidth(
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 5,
                        bottom: 5,
                        right: 10,
                        left: context.width * 0.2,
                      ),
                      padding: const EdgeInsets.all(10),
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
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8, // Adjust max width as needed
                              ),
                              child: Text(
                                "${chat[index].content}",
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          if (chat[index].mediaLink != null)
                            if (chat[index].type == MediaType.image)
                              GestureDetector(
                                onTap: () {},
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: chat[index].mediaLink!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.image),
                                  ),
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
                              DateFormat.jm().format(chat[index].timestamp!),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            );
          } else {
            return Align(
              alignment: Alignment.topLeft,
              child: IntrinsicWidth(
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: chat[index].mediaLink!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.image),
                              ),
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
                          DateFormat.jm().format(chat[index].timestamp!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
