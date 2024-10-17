import 'package:cached_network_image/cached_network_image.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/core/router/router.dart';
import 'package:enigma/src/core/utils/extension/context_extension.dart';
import 'package:enigma/src/features/profile/domain/entity/profile_entity.dart';
import 'package:enigma/src/features/profile/presentation/view_model/controller/profile_controller.dart';
import 'package:enigma/src/features/profile/presentation/view_model/generic/profile_generic.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:enigma/src/shared/widgets/shared_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  ProfileScreen({super.key, required this.data});

  static const String route = "/profile";
  ProfileEntity data;

  static setRoute() => "/profile";

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  SharedPreferenceManager sp = sl.get<SharedPreferenceManager>();

  Widget build(BuildContext context) {
    ProfileGeneric profileController = ref.watch(profileProvider);
    final ProfileEntity profileEntity = widget.data;
    return Scaffold(
      appBar: SharedAppbar(
        leadingWidget: InkWell(
          onTap: () {
            ref.read(goRouterProvider).pop();
          },
          child: Container(
            height: context.height * .05,
            width: context.width * .05,
            margin: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_outlined,
                size: 25,
              ),
            ),
          ),
        ),
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: buildImageSection(context, profileEntity),
              ),
              const SizedBox(
                height: 40,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDisplayNameSection(context, profileEntity),
                  const SizedBox(
                    height: 20,
                  ),
                  buildEmailSection(context, profileEntity),
                  const SizedBox(
                    height: 20,
                  ),
                  buildPhoneNumberSection(context, profileEntity),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPhoneNumberSection(
      BuildContext context, ProfileEntity profileEntity) {
    return SizedBox(
        height: context.height * 0.06,
        //color: Colors.amber,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Phone Number",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "${profileEntity.phoneNumber ?? "-"}",
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ));
  }

  Widget buildEmailSection(BuildContext context, ProfileEntity profileEntity) {
    return SizedBox(
        height: context.height * 0.06,
        //color: Colors.amber,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Email",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  profileEntity.email ?? "-",
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ));
  }

  Widget buildDisplayNameSection(
      BuildContext context, ProfileEntity profileEntity) {
    return SizedBox(
        height: context.height * 0.06,
        //color: Colors.amber,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Display name",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  "${profileEntity.name ?? "-"}",
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ));
  }

  Widget buildImageSection(BuildContext context, ProfileEntity profileEntity) {
    return Column(
      children: [
        Align(
          alignment: Alignment.center,
          child: ClipOval(
            child: CachedNetworkImage(
              height: context.width * 0.4,
              width: context.width * 0.4,
              imageUrl: profileEntity.avatarUrl ?? "",
              errorWidget: (context, url, error) => Icon(
                Icons.person,
                size: context.width * 0.1,
              ),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "${profileEntity.name}",
          style: Theme.of(context).textTheme.headlineSmall,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
