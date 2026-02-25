import 'dart:io';
import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Results")),
      body: Column(
        children: [
          // Display the captured image
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.black12,
            child: Image.file(imageFile, fit: BoxFit.contain),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text("Detected Language: ${languageCode.toUpperCase()}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const Divider(),
                  const Text("Extracted Text:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SelectableText(recognizedText.isEmpty ? "No text found." : recognizedText),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Trigger Translation
              },
              icon: const Icon(Icons.translate),
              label: const Text("Translate to English"),
            ),
          )
        ],
      ),
    );
  }
}