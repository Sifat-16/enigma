import 'dart:convert';
import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_keys.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/network/remote/firebase/firebase_storage_directory_name.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/core/utils/logger/logger.dart';
import 'package:enigma/src/core/utils/restart_widget/restart_widget.dart';
import 'package:enigma/src/features/auth/presentation/auth_screen/view/auth_screen.dart';
import 'package:enigma/src/features/auth/presentation/auth_screen/view_model/auth_controller.dart';
import 'package:enigma/src/features/auth/presentation/logout/view_model/logout_controller.dart';
import 'package:enigma/src/features/chat/presentation/components/chat_screen_bottom_bar.dart';
import 'package:enigma/src/features/chat/presentation/view-model/chat_controller.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/features/profile/presentation/view_model/controller/profile_controller.dart';
import 'package:enigma/src/features/profile/presentation/view_model/generic/profile_generic.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/widgets/shared_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const route = "/settings";

  static setRoute() => "/settings";

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  SharedPreferenceManager sharedPreferenceManager =
      sl.get<SharedPreferenceManager>();
  TextEditingController nameTEC = TextEditingController();
  TextEditingController emailTEC = TextEditingController();
  TextEditingController phoneNumberTEC = TextEditingController();
  bool isLightMode = false;
  static const platform = MethodChannel('com.wakil_training_.enigma/ram');
  String _ramUsage = "Unknown";

  Future<void> _getRamUsage() async {
    try {
      final String ramUsage = await platform.invokeMethod('getRamUsage');
      setState(() {
        _ramUsage = ramUsage;
      });
    } on PlatformException catch (e) {
      print("Failed to get RAM usage: '${e.message}'.");
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      ref.read(profileProvider.notifier).readProfile(
          sharedPreferenceManager.getValue(key: SharedPreferenceKeys.USER_UID));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ProfileGeneric profileController = ref.watch(profileProvider);
    return Scaffold(
      appBar: SharedAppbar(
          leadingWidget: GestureDetector(
            onTap: () async {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Scan to send chat request',
                      textAlign: TextAlign.center,
                    ),
                    content: SingleChildScrollView(
                        child: BarcodeWidget(
                      barcode: Barcode.qrCode(),
                      data: jsonEncode(profileController.profileEntity),
                      drawText: true,
                    )),
                  );
                },
              );
            },
            child: const Icon(
              Icons.qr_code_scanner,
              size: 25,
            ),
          ),
          title: const Text("Settings"),
          trailingWidgets: [
            GestureDetector(
              onTap: () async {
                await ref.read(profileProvider.notifier).toggleThemeMode(
                    isLightMode: !profileController.isLightMode);
                debug("light mode set : ${!profileController.isLightMode}");
                sharedPreferenceManager.insertValue(
                    key: SharedPreferenceKeys.IS_LIGHT_MODE,
                    data: !profileController.isLightMode);
                RestartWidget.restartApp(context);
              },
              child: Container(
                width: context.width * .1,
                height: context.width * .1,
                margin: const EdgeInsets.all(8),
                child: Icon(
                  profileController.isLightMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  size: 25,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                bool isSuccess = false;
                isSuccess = await ref.read(logoutProvider.notifier).logout();
                if (isSuccess) {
                  ref.read(goRouterProvider).go(AuthScreen.route);
                }
              },
              child: Container(
                width: context.width * .1,
                height: context.width * .1,
                margin: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.logout,
                  size: 25,
                ),
              ),
            )
          ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: buildImageSection(context, profileController),
              ),
              const SizedBox(
                height: 40,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDisplayNameSection(context, profileController),
                  const SizedBox(
                    height: 20,
                  ),
                  buildEmailSection(context, profileController),
                  const SizedBox(
                    height: 20,
                  ),
                  buildPhoneNumberSection(context, profileController),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          await _getRamUsage();
                          BotToast.showText(text: _ramUsage);
                        },
                        child: const Text("Check RAM USAGE")),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPhoneNumberSection(
      BuildContext context, ProfileGeneric profileController) {
    return SizedBox(
      height: context.height * 0.06,
      //color: Colors.amber,
      child: !profileController.phoneNumberEditInProgress
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Phone Number",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text("${profileController.profileEntity?.phoneNumber}",
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: IconButton(
                    onPressed: () async {
                      phoneNumberTEC.text =
                          profileController.profileEntity?.phoneNumber ?? "";
                      ref
                          .read(profileProvider.notifier)
                          .toggleProfileEdit("phoneNumber");
                    },
                    icon: const Icon(
                      Icons.edit,
                    ),
                  ),
                )
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 4,
                  child: TextFormField(
                    controller: phoneNumberTEC,
                    maxLines: null,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.3),
                      hintText: "Phone Number",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: IconButton(
                    onPressed: () async {
                      if (profileController.profileEntity != null) {
                        ProfileEntity updatedProfile =
                            profileController.profileEntity!;
                        if (phoneNumberTEC.text.trim().toLowerCase() ==
                            profileController.profileEntity?.phoneNumber) {
                          ref
                              .read(profileProvider.notifier)
                              .toggleProfileEdit("phoneNumber");
                          return;
                        }
                        updatedProfile.phoneNumber = phoneNumberTEC.text.trim();
                        ref
                            .read(profileProvider.notifier)
                            .updateProfile(updatedProfile);
                        ref
                            .read(profileProvider.notifier)
                            .readProfile(updatedProfile.uid ?? "");
                      }
                      ref
                          .read(profileProvider.notifier)
                          .toggleProfileEdit("phoneNumber");
                    },
                    icon: const Icon(
                      Icons.check,
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget buildEmailSection(
      BuildContext context, ProfileGeneric profileController) {
    return SizedBox(
      height: context.height * 0.06,
      //color: Colors.amber,
      child: !profileController.emailEditInProgress
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Email",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                          "${sharedPreferenceManager.getValue(key: SharedPreferenceKeys.USER_EMAIL)}",
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: IconButton(
                    onPressed: () async {
                      emailTEC.text = sharedPreferenceManager.getValue(
                          key: SharedPreferenceKeys.USER_EMAIL);
                      ref
                          .read(profileProvider.notifier)
                          .toggleProfileEdit("email");
                    },
                    icon: const Icon(
                      Icons.edit,
                    ),
                  ),
                )
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 4,
                  child: TextFormField(
                    controller: emailTEC,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.3),
                      hintText: "Email",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: IconButton(
                    onPressed: () async {
                      bool isSuccess = false;

                      if (emailTEC.text.trim().toLowerCase() ==
                          sharedPreferenceManager.getValue(
                              key: SharedPreferenceKeys.USER_EMAIL)) {
                        ref
                            .read(profileProvider.notifier)
                            .toggleProfileEdit("email");
                        return;
                      }

                      List<ProfileEntity> listOfAllProfiles =
                          ref.read(profileProvider).listOfAllProfiles;

                      for (ProfileEntity p in listOfAllProfiles) {
                        if (p.email?.toLowerCase() ==
                            emailTEC.text.trim().toLowerCase()) {
                          BotToast.showText(text: "Email already in use");
                          return;
                        }
                      }

                      if (profileController.profileEntity != null) {
                        ProfileEntity updatedProfile =
                            profileController.profileEntity!;
                        updatedProfile.email = emailTEC.text.trim();
                        isSuccess = await ref
                            .read(authProvider.notifier)
                            .changeEmail(email: updatedProfile.email!);

                        if (isSuccess) {
                          showDialog<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: const SingleChildScrollView(
                                    child: Column(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 50,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "A verification email has been sent to your new email. please verify the email from the link.",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )),
                                actions: [
                                  TextButton(
                                    child: const Text('Ok'),
                                    onPressed: () async {
                                      await ref
                                          .read(logoutProvider.notifier)
                                          .logout();
                                      ref
                                          .read(goRouterProvider)
                                          .go(AuthScreen.setRoute());
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                      ref
                          .read(profileProvider.notifier)
                          .toggleProfileEdit("email");
                    },
                    icon: const Icon(
                      Icons.check,
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget buildDisplayNameSection(
      BuildContext context, ProfileGeneric profileController) {
    return SizedBox(
      height: context.height * 0.06,
      //color: Colors.amber,
      child: !profileController.nameEditInProgress
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Display name",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text("${profileController.profileEntity?.name}",
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: IconButton(
                    onPressed: () async {
                      nameTEC.text =
                          profileController.profileEntity?.name ?? "";
                      ref
                          .read(profileProvider.notifier)
                          .toggleProfileEdit("name");
                    },
                    icon: const Icon(
                      Icons.edit,
                    ),
                  ),
                )
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 4,
                  child: TextFormField(
                    controller: nameTEC,
                    maxLines: null,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.3),
                      hintText: "Display name",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: IconButton(
                    onPressed: () async {
                      if (profileController.profileEntity != null) {
                        if (nameTEC.text.trim() ==
                            profileController.profileEntity?.name) {
                          debug("In name");
                          ref
                              .read(profileProvider.notifier)
                              .toggleProfileEdit("name");
                          return;
                        }

                        ProfileEntity updatedProfile =
                            profileController.profileEntity!;
                        updatedProfile.name = nameTEC.text.trim();
                        ref
                            .read(profileProvider.notifier)
                            .updateProfile(updatedProfile);
                        ref
                            .read(profileProvider.notifier)
                            .readProfile(updatedProfile.uid ?? "");
                      }
                      ref
                          .read(profileProvider.notifier)
                          .toggleProfileEdit("name");
                    },
                    icon: const Icon(
                      Icons.check,
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget buildImageSection(
      BuildContext context, ProfileGeneric profileController) {
    return Column(
      children: [
        Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipOval(
                child: CachedNetworkImage(
                  height: context.width * 0.4,
                  width: context.width * 0.4,
                  imageUrl: profileController.profileEntity?.avatarUrl ?? "",
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: context.width * 0.1,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: context.width / 4,
              child: IconButton(
                onPressed: () async {
                  _showOptions(context, profileController);
                },
                icon: const Icon(
                  Icons.edit,
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "${profileController.profileEntity?.name}",
          style: Theme.of(context).textTheme.headlineSmall,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showOptions(BuildContext context, ProfileGeneric profileController) {
    showBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            filesOption(
              title: "Camera",
              subtitle: "Take a picture",
              onTap: () async {
                File? imageFile =
                    await pickImage(imageSource: ImageSource.camera);
                String? url;
                if (imageFile != null) {
                  url = await ref.read(chatProvider.notifier).addImageMedia(
                        file: imageFile,
                        directory: FirebaseStorageDirectoryName
                            .PROFILE_PICTURE_DIRECTORY,
                        fileName: "${profileController.profileEntity?.uid}.jpg",
                      );
                }
                if (imageFile != null) {
                  ProfileEntity updatedProfile =
                      profileController.profileEntity!;
                  updatedProfile.avatarUrl = url;
                  ref
                      .read(profileProvider.notifier)
                      .updateProfile(updatedProfile);
                  ref
                      .read(profileProvider.notifier)
                      .readProfile(updatedProfile.uid ?? "");
                }
              },
              icon: Icons.camera,
            ),
            filesOption(
              title: "Gallery",
              subtitle: "Set picture from gallery",
              onTap: () async {
                File? imageFile =
                    await pickImage(imageSource: ImageSource.gallery);
                String? url;
                if (imageFile != null) {
                  url = await ref.read(chatProvider.notifier).addImageMedia(
                        file: imageFile,
                        directory: FirebaseStorageDirectoryName
                            .PROFILE_PICTURE_DIRECTORY,
                        fileName: "${profileController.profileEntity?.uid}.jpg",
                      );
                }
                if (imageFile != null) {
                  ProfileEntity updatedProfile =
                      profileController.profileEntity!;
                  updatedProfile.avatarUrl = url;
                  ref
                      .read(profileProvider.notifier)
                      .updateProfile(updatedProfile);
                  ref
                      .read(profileProvider.notifier)
                      .readProfile(updatedProfile.uid ?? "");
                }
              },
              icon: Icons.image,
            ),
          ],
        );
      },
    );
  }

  static Future<File?> pickImage({required ImageSource imageSource}) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? getImage = await imagePicker.pickImage(
      source: imageSource,
    );
    File? file;
    if (getImage != null) {
      file = File(getImage.path);
      return file;
    } else {
      return null;
    }
  }
}
