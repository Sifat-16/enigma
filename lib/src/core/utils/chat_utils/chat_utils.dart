import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ChatUtils {
  static Future<File?> pickImage({required ImageSource imageSource}) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? getImage = await imagePicker.pickImage(
      source: imageSource,
      imageQuality: 30,
    );
    File? file;
    if (getImage != null) {
      file = File(getImage.path);
      return file;
    } else {
      return null;
    }
  }

  static Future<File?> pickDocuments(List<String> extensions) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      allowedExtensions: extensions,
      type: FileType.custom,
    );
    File file;
    if (result != null) {
      file = File(result.paths.first!);
      return file;
    } else {
      return null;
    }
  }

  static Future<String> textRecognition(File file) async {
    final InputImage inputImage = InputImage.fromFile(file);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    String text = recognizedText.text;
    return text;
  }

  static void startRecord(AudioRecorder record) async {
    try {
      if (await record.hasPermission()) {
        final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
        await record.start(const RecordConfig(), path: "${appDocumentsDir.path}/recording.m4a");
      }
    } catch (e) {
      return;
    }
  }

  static Future<String> stopRecord(AudioRecorder record) async {
    final String? path = await record.stop();
    File file = File(path!);
    return path;
  }

  static void playRecord(String path, AudioPlayer audioPlayer) async {
    Source audioUrl = UrlSource(path);
    await audioPlayer.play(audioUrl, volume: 10);
  }

  static void pauseRecord(AudioPlayer audioPlayer) async {
    await audioPlayer.pause();
  }
}
