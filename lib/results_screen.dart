import 'dart:io';
import 'package:flutter/material.dart';
import 'services/ml_service.dart';

class ResultsScreen extends StatefulWidget {
  final File imageFile;
  final String recognizedText;
  final String languageCode;

  const ResultsScreen({
    super.key,
    required this.imageFile,
    required this.recognizedText,
    required this.languageCode,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final MLService _mlService = MLService();

  String _translatedText = "";
  bool _isTranslating = false;
  String _targetLanguage = "en";

  Future<void> _handleTranslation() async {
    setState(() => _isTranslating = true);

    try {
      final result = await _mlService.translateText(
        widget.recognizedText,
        widget.languageCode,
        _targetLanguage,
      );

      setState(() => _translatedText = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Translation failed: ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isTranslating = false);
    }
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }

  String _languageName(String code) {
    switch (code) {
      case "en":
        return "English";
      case "fr":
        return "French";
      case "ar":
        return "Arabic";
      default:
        return code.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Results"),
      ),
      body: Column(
        children: [
          // -------- IMAGE --------
          SizedBox(
            height: 220,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // -------- CONTENT --------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Text(
                    "Detected Language: ${_languageName(widget.languageCode)}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),

                  const SizedBox(height: 10),
                  const Text(
                    "Original Text",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.recognizedText),

                  const SizedBox(height: 30),

                  // -------- TARGET LANGUAGE DROPDOWN --------
                  DropdownButtonFormField<String>(
                    value: _targetLanguage,
                    decoration: const InputDecoration(
                      labelText: "Translate To",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "en",
                        child: Text("English"),
                      ),
                      DropdownMenuItem(
                        value: "fr",
                        child: Text("French"),
                      ),
                      DropdownMenuItem(
                        value: "ar",
                        child: Text("Arabic"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _targetLanguage = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  if (_translatedText.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 10),
                    Text(
                      "Translated Text",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _translatedText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // -------- BUTTON --------
          Padding(
            padding: const EdgeInsets.all(20),
            child: _isTranslating
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _handleTranslation,
                      icon: const Icon(Icons.translate),
                      label: const Text("Translate"),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}