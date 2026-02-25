import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/ml_service.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool)? toggleTheme;
  final Function(String)? changeLanguage;

  const HomeScreen({
    super.key,
    this.toggleTheme,
    this.changeLanguage,
  });

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

      final String text = await _mlService.recognizeText(file);

      if (text.trim().isEmpty) {
        throw Exception("No text detected.");
      }

      final String langCode = await _mlService.identifyLanguage(text);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            imageFile: file,
            recognizedText: text,
            languageCode: langCode,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Image Source",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _processImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _processImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("LingoLens AI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // We'll implement settings screen next
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // --- App Icon ---
                  Icon(
                    Icons.translate,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 20),

                  // --- App Title ---
                  Text(
                    "Translate the World Instantly",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Capture text from images and translate it instantly using AI-powered recognition.",
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 50),

                  // --- Scan Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: FilledButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.document_scanner),
                      label: const Text(
                        "Scan Text",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // --- About Section ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "About",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "LingoLens AI is a mobile application that uses Google ML Kit "
                    "to extract text from images, detect its language, and translate "
                    "it instantly. Designed for travelers, students, and professionals.",
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
    );
  }
}