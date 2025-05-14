import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({Key? key}) : super(key: key);

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    // Filter for .png and .webp files in desired folders
    final images = manifestMap.keys.where((String key) =>
        (key.startsWith('assets/images/png/') || key.startsWith('assets/images/webp/')) &&
        (key.endsWith('.png') || key.endsWith('.webp'))).toList();

    setState(() {
      imagePaths = images;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select an Image')),
      body: imagePaths.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.pop(context, imagePaths[index]),
                  child: Image.asset(imagePaths[index], fit: BoxFit.cover),
                );
              },
            ),
    );
  }
}
