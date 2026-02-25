import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class MLService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  final LanguageIdentifier _languageIdentifier =
      LanguageIdentifier(confidenceThreshold: 0.5);

  OnDeviceTranslator? _translator;

  // -------------------------------
  // TEXT RECOGNITION
  // -------------------------------
  Future<String> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);

    return recognizedText.text;
  }

  // -------------------------------
  // LANGUAGE IDENTIFICATION
  // -------------------------------
  Future<String> identifyLanguage(String text) async {
    if (text.trim().isEmpty) return 'und';

    final languageCode =
        await _languageIdentifier.identifyLanguage(text);

    return languageCode;
  }

  // -------------------------------
  // TRANSLATION
  // -------------------------------
  Future<String> translateText(
      String text,
      String sourceLanguage,
      String targetLanguage,
      ) async {
    if (text.trim().isEmpty) return '';

    try {
      final source =
          TranslateLanguage.values.firstWhere(
                (e) => e.bcpCode == sourceLanguage,
            orElse: () => TranslateLanguage.english,
          );

      final target =
          TranslateLanguage.values.firstWhere(
                (e) => e.bcpCode == targetLanguage,
            orElse: () => TranslateLanguage.english,
          );

      _translator?.close();

      _translator = OnDeviceTranslator(
        sourceLanguage: source,
        targetLanguage: target,
      );

      final translatedText =
      await _translator!.translateText(text);

      return translatedText;
    } catch (e) {
      return "Translation unavailable";
    }
  }

  // -------------------------------
  // DISPOSE
  // -------------------------------
  void dispose() {
    _textRecognizer.close();
    _languageIdentifier.close();
    _translator?.close();
  }
}