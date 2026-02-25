import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class MLService {
  // 1. Initialize the OCR engine
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  
  // 2. Initialize Language Identifier
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  // Method to extract text from an image file
  Future<String> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  // Method to identify the language
  Future<String> identifyLanguage(String text) async {
    final String languageCode = await _languageIdentifier.identifyLanguage(text);
    return languageCode; // Returns codes like 'en', 'fr', 'ar'
  }

  // Close resources to prevent memory leaks (Very important for mobile!)
  void dispose() {
    _textRecognizer.close();
    _languageIdentifier.close();
  }
}