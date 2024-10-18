import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:voice_message_package/voice_message_package.dart';

class VoiceMessageViewWidget extends StatefulWidget {
  const VoiceMessageViewWidget(
      {super.key, required this.url, required this.isFile});

  final String url;
  final bool isFile;

  @override
  State<VoiceMessageViewWidget> createState() => _VoiceMessageViewState();
}

class _VoiceMessageViewState extends State<VoiceMessageViewWidget> {
  ValueNotifier<Duration?> duration = ValueNotifier<Duration?>(null);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (t) async {
        AudioPlayer player = AudioPlayer();
        await player.setVolume(0);
        await player.play(UrlSource(widget.url ?? ""));
        // await player.setSource(UrlSource(widget.url ?? ""));
        duration.value = await player.getDuration();
        await player.stop();
        // debug(duration?.inSeconds);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: duration,
      builder: (context, value, child) {
        if (value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return VoiceMessageView(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          circlesColor: Theme.of(context).colorScheme.primary,
          activeSliderColor: Theme.of(context).colorScheme.onPrimary,
          // notActiveSliderColor:
          //     Theme.of(context).colorScheme.primary.withOpacity(0.2),
          controller: VoiceController(
            audioSrc: widget.url,
            isFile: widget.isFile,
            maxDuration: value,
            onComplete: () {},
            onPause: () {},
            onPlaying: () {},
          ),
        );
      },
    );
  }
}
