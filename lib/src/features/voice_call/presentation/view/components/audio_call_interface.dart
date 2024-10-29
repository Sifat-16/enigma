import 'package:cached_network_image/cached_network_image.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_keys.dart';
import 'package:enigma/src/core/database/local/shared_preference/shared_preference_manager.dart';
import 'package:enigma/src/features/voice_call/data/model/call_model.dart';
import 'package:enigma/src/shared/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';

class AudioCallInterface extends StatefulWidget {
  const AudioCallInterface({super.key, required this.callModel});
  final CallModel callModel;
  @override
  State<AudioCallInterface> createState() => _AudioCallInterfaceState();
}

class _AudioCallInterfaceState extends State<AudioCallInterface> {
  SharedPreferenceManager sharedPreferenceManager =
      sl.get<SharedPreferenceManager>();
  late String userUid;
  @override
  void initState() {
    userUid =
        sharedPreferenceManager.getValue(key: SharedPreferenceKeys.USER_UID);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                imageUrl: userUid == widget.callModel.receiverUid
                    ? widget.callModel.senderAvatar ?? ""
                    : widget.callModel.receiverAvatar ?? "",
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.person),
              ),
            ),
          ),
          Text(
            userUid == widget.callModel.receiverUid
                ? widget.callModel.senderName ?? ""
                : widget.callModel.receiverName ?? "",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
