import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  OcrService() : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  Future<String> scanReceipt(File file) async {
    final inputImage = InputImage.fromFile(file);
    final result = await _recognizer.processImage(inputImage);
    final buffer = StringBuffer();
    for (final block in result.blocks) {
      buffer.writeln(block.text);
    }
    return buffer.toString().trim();
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}
