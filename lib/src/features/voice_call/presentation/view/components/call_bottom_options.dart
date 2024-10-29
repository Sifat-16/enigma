// import 'package:flutter/material.dart';
// class CallBottomOptions extends StatefulWidget {
//   const CallBottomOptions({super.key});
//
//   @override
//   State<CallBottomOptions> createState() => _CallBottomOptionsState();
// }
//
// class _CallBottomOptionsState extends State<CallBottomOptions> {
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         height: context.height * 0.1,
//         margin: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color: Theme.of(context).colorScheme.secondary,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             InkWell(
//               onTap: () async {
//                 await ref
//                     .read(callProvider.notifier)
//                     .muteLocalAudioStream();
//                 // print(ref.read(callProvider).muteVoice);
//               },
//               child: Icon(
//                 Icons.mic_off,
//                 color: call.muteVoice
//                     ? Colors.red
//                     : Colors.black,
//               ),
//             ),
//             InkWell(
//               onTap: () async {
//                 await ref
//                     .read(callProvider.notifier)
//                     .leaveChannel(
//                     callModel: widget.callModel);
//                 await ref
//                     .read(callProvider.notifier)
//                     .sendCallEndNotification(
//                     callModel: widget.callModel);
//                 if(widget.isCalling) {
//                   container.read(goRouterProvider).pop();
//                 }
//                 else {
//                   ref.read(callStateProvider.notifier).state = CallState.ended;
//                 }
//
//               },
//               child: const Icon(
//                 Icons.call_end,
//                 color: Colors.red,
//               ),
//             ),
//             InkWell(
//               onTap: () async {
//                 await ref
//                     .read(callProvider.notifier)
//                     .muteLocalVideoStream();
//                 // await ref
//                 //     .read(callProvider.notifier)
//                 //     .muteAllRemoteVideoStreams();
//               },
//               child: Icon(
//                 Icons.videocam_off,
//                 color: call.muteCamera
//                     ? Colors.red
//                     : Colors.black,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),;
//   }
// }
