import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:voice_message_package/voice_message_package.dart';

class VoiceMessageViewWidget extends StatefulWidget {
  const VoiceMessageViewWidget({super.key, required this.url, required this.isFile});

  final String url;
  final bool isFile;

  @override
  State<VoiceMessageViewWidget> createState() => _VoiceMessageViewState();
}

class _VoiceMessageViewState extends State<VoiceMessageViewWidget> {
  AudioPlayer player = AudioPlayer();
  ValueNotifier<Duration?> duration = ValueNotifier<Duration>(const Duration(seconds: 0));

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    if (widget.url.isNotEmpty) {
      try {
        if (widget.isFile) {
          await player.setSourceDeviceFile(widget.url);
        } else {
          await player.setSourceUrl(widget.url);
        }
        Duration? audioDuration = await player.getDuration();
        duration.value = audioDuration;
        // setState(() {
        //   duration = audioDuration;
        // });
      } catch (e) {
        print("Error initializing audio: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration?>(
      valueListenable: duration,
      builder: (context, value, child) {
        if(value == null) return const SizedBox.shrink();
        return VoiceMessageView(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          circlesColor: Theme.of(context).colorScheme.primary,
          activeSliderColor: Theme.of(context).colorScheme.onPrimary,
          controller: VoiceController(
            audioSrc: widget.url,
            isFile: widget.isFile,
            maxDuration: value,
            onComplete: () {},
            onPause: () {},
            onPlaying: () {},
          ),
        );
      }
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
