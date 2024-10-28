import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:enigma/src/core/network/remote/firebase/firebase_handler.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/features/chat_request/presentation/view/friends_screen.dart';
import 'package:enigma/src/features/chat_request/presentation/view_model/chat_request_controller.dart';
import 'package:enigma/src/features/chat_request/presentation/view_model/chat_request_generic.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/features/profile/presentation/view_model/controller/profile_controller.dart';
import 'package:enigma/src/features/profile/presentation/view_model/generic/profile_generic.dart';
import 'package:enigma/src/shared/widgets/circular_display_picture.dart';
import 'package:enigma/src/shared/widgets/shared_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_dart_scan/qr_code_dart_scan.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  PeopleScreen({super.key, required this.data});

  Map<String, dynamic> data;
  ProfileEntity? peopleEntity;
  static const route = "/people/:people_entity";

  static setRoute({required ProfileEntity profileEntity}) =>
      "/people/${jsonEncode(profileEntity.toJson())}";

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  String _scanBarcode = 'Unknown';

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    WidgetsBinding.instance.addPostFrameCallback((t) async {
      await ref.read(chatRequestProvider.notifier).fetchPendingRequest();
      await ref.read(chatRequestProvider.notifier).fetchChatRequest();
      await ref.read(profileProvider.notifier).readAllPeople();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileGeneric profileController = ref.watch(profileProvider);
    final ChatRequestGeneric chatRequestController =
        ref.watch(chatRequestProvider);
    ref.watch(chatRequestProvider);

    return Scaffold(
      appBar: SharedAppbar(
          title: Text("People"),
          // leadingWidget: GestureDetector(
          //   onTap: () {},
          //   child: const Icon(
          //     Icons.search,
          //     size: 25,
          //   ),
          // ),
          trailingWidgets: [
            GestureDetector(
              onTap: () async {
                ProfileEntity profileEntity;
                String scanDetails = "";
                // // Simple Barcode Scanner Package
                // var res = await Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) => const SimpleBarcodeScannerPage(),
                //     ));
                // if (res is String) {
                //   scanDetails = res;
                //   profileEntity =
                //       ProfileEntity.fromJson(jsonDecode(scanDetails));
                //   debug(profileEntity.name);
                //   showSendChatRequestDialog(profileEntity, profileController);
                // }
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: const Text('Scan QR Code'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            QRCodeDartScanView(
                              typeScan: TypeScan.live,
                              formats: const [
                                BarcodeFormat.qrCode,
                              ],
                              onCapture: (Result result) {
                                scanDetails = result.text;
                                profileEntity = ProfileEntity.fromJson(
                                    jsonDecode(scanDetails));
                                debug(profileEntity.name);
                                ref.read(goRouterProvider).pop();
                                showSendChatRequestDialog(
                                    profileEntity, profileController);
                              },
                            ),
                          ],
                        ));
                  },
                );
              },
              child: Container(
                width: context.width * .1,
                height: context.width * .1,
                margin: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 25,
                ),
              ),
            )
          ]),
      body: RefreshIndicator(
        onRefresh: () async {
          init();
        },
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) => SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Chat requests
                  buildFriendsSection(context, chatRequestController),
                  // People list
                  if (chatRequestController.listOfChatRequest.isNotEmpty)
                    buildChatRequestsSection(
                        context, profileController, chatRequestController),
                  if (chatRequestController.listOfPendingRequest.isNotEmpty)
                    buildPendingRequestsSection(
                        context, profileController, chatRequestController),
                  if (profileController.listOfPeople.isNotEmpty)
                    buildDiscoverSection(
                        context, profileController, chatRequestController)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  showSendChatRequestDialog(
      ProfileEntity profileEntity, ProfileGeneric profileController) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send Chat Request'),
          content: SingleChildScrollView(
              child: Container(
            child: Column(
              children: [
                CircularDisplayPicture(
                  radius: 23,
                  imageURL: profileEntity.avatarUrl,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  profileEntity.name ?? "",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text("Send chat request?"),
              ],
            ),
          )),
          actions: <Widget>[
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                if (profileController.listOfFriends
                    .any((p) => p.uid == profileEntity.uid)) {
                  BotToast.showText(text: "User is already your friend");
                  ref.read(goRouterProvider).pop();
                  return;
                }
                ref
                    .read(chatRequestProvider.notifier)
                    .sendChatRequest(profileEntity);
                ref.read(goRouterProvider).pop();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                ref.read(goRouterProvider).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildFriendsSection(
      BuildContext context, ChatRequestGeneric chatRequestController) {
    return InkWell(
      onTap: () {
        ref.read(goRouterProvider).push(FriendsScreen.route);
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          //border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Friends",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).canvasColor),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: Theme.of(context).canvasColor,
            )
          ],
        ),
      ),
    );
  }

  Widget buildChatRequestsSection(
      BuildContext context,
      ProfileGeneric profileController,
      ChatRequestGeneric chatRequestController) {
    return Container(
      padding: const EdgeInsets.all(20),
      //color: Colors.grey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Chat requests"),
          const SizedBox(
            height: 20,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircularDisplayPicture(
                        radius: 23,
                        imageURL: chatRequestController
                            .listOfChatRequest[index].avatarUrl,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chatRequestController
                                    .listOfChatRequest[index].name ??
                                "",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                              chatRequestController
                                      .listOfChatRequest[index].createdAt
                                      .toString() ??
                                  "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall)
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () async {
                          String receiverUid = chatRequestController
                                  .listOfChatRequest[index].uid ??
                              "";
                          String status = "accepted";
                          await ref
                              .read(chatRequestProvider.notifier)
                              .updateRequestStatus(status, receiverUid);
                        },
                        icon: const Icon(
                          Icons.check,
                        ),
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                      ),
                      IconButton(
                        onPressed: () async {
                          String receiverUid = chatRequestController
                                  .listOfChatRequest[index].uid ??
                              "";
                          String status = "rejected";
                          await ref
                              .read(chatRequestProvider.notifier)
                              .updateRequestStatus(status, receiverUid);
                        },
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                      ),
                    ],
                  )
                ],
              );
            },
            itemCount: chatRequestController.listOfChatRequest.length,
          ),
        ],
      ),
    );
  }

  Widget buildPendingRequestsSection(
      BuildContext context,
      ProfileGeneric profileController,
      ChatRequestGeneric chatRequestController) {
    return Container(
      padding: const EdgeInsets.all(20),
      //color: Colors.grey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pending requests"),
          const SizedBox(
            height: 20,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircularDisplayPicture(
                      radius: 23,
                      imageURL: chatRequestController
                          .listOfPendingRequest[index].avatarUrl,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chatRequestController
                                  .listOfPendingRequest[index].name ??
                              "",
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                            chatRequestController
                                    .listOfPendingRequest[index].createdAt
                                    .toString() ??
                                "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall)
                      ],
                    ),
                  ],
                ),
              );
            },
            itemCount: chatRequestController.listOfPendingRequest.length,
          ),
        ],
      ),
    );
  }

  Widget buildDiscoverSection(
      BuildContext context,
      ProfileGeneric profileController,
      ChatRequestGeneric chatRequestController) {
    return Container(
      padding: const EdgeInsets.all(20),
      //color: Colors.grey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Discover"),
          const SizedBox(
            height: 20,
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircularDisplayPicture(
                          radius: 23,
                          imageURL:
                              profileController.listOfPeople[index].avatarUrl,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileController.listOfPeople[index].name ?? "",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                                profileController.listOfPeople[index].createdAt
                                        .toString() ??
                                    "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall)
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        // todo: implement sembast for sender uid
                        String sender =
                            FirebaseHandler.auth.currentUser?.uid ?? "";
                        String receiver =
                            profileController.listOfPeople[index].uid ?? "";
                        await ref
                            .read(chatRequestProvider.notifier)
                            .sendChatRequest(
                                profileController.listOfPeople[index]);
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                    )
                  ],
                ),
              );
            },
            itemCount: profileController.listOfPeople.length,
          ),
        ],
      ),
    );
  }
}
