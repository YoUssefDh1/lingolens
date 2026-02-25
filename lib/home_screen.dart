import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/ml_service.dart';
import 'results_screen.dart'; // We'll create this next

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final MLService _mlService = MLService();
  bool _isLoading = false;

  Future<void> _processImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final File file = File(image.path);
      
      // 1. Recognize Text
      final String text = await _mlService.recognizeText(file);
      
      // 2. Identify Language
      final String langCode = await _mlService.identifyLanguage(text);

      // Navigate to results
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            imageFile: file,
            recognizedText: text,
            languageCode: langCode,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error processing image: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LingoLens AI')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text("Select an image to translate", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.camera_alt, "Camera", ImageSource.camera),
                    _buildActionButton(Icons.photo_library, "Gallery", ImageSource.gallery),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, ImageSource source) {
    return Column(
      children: [
        IconButton.filledTonal(
          iconSize: 40,
          onPressed: () => _processImage(source),
          icon: Icon(icon),
        ),
        Text(label),
      ],
    );
  }
}