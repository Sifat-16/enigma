import 'package:cached_network_image/cached_network_image.dart';
import 'package:enigma/src/features/voice_call/data/model/call_model.dart';
import 'package:flutter/material.dart';
class AudioCallInterface extends StatefulWidget {
  const AudioCallInterface({super.key, required this.callModel});
  final CallModel callModel;
  @override
  State<AudioCallInterface> createState() => _AudioCallInterfaceState();
}

class _AudioCallInterfaceState extends State<AudioCallInterface> {
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
                imageUrl: widget.callModel.receiverAvatar ?? "",
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                const Icon(Icons.person),
              ),
            ),
          ),
          Text(
            "${widget.callModel.receiverName}",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
