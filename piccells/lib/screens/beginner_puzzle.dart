import 'package:flutter/material.dart';
import 'package:piccells/screens/image_picker_screen.dart';
import 'package:piccells/screens/slide_puzzle.dart';
import 'package:piccells/screens/swap_puzzle.dart';

class BeginnerPuzzleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Beginner Puzzle - Choose Mode")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              // Navigate to ImagePickerScreen for Slide Puzzle
              String? imagePath = await _selectImage(context);
              if (imagePath.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SlidePuzzleScreen(imagePath: imagePath),
                  ),
                );
              }
            },
            child: Text("Slide Puzzle"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Navigate to ImagePickerScreen for Swap Puzzle
              String? imagePath = await _selectImage(context);
              if (imagePath.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SwapPuzzleScreen(imagePath: imagePath),
                  ),
                );
              }
            },
            child: Text("Swap Puzzle"),
          ),
        ],
      ),
    );
  }

  // Function to navigate to ImagePickerScreen and get the selected image
  Future<String> _selectImage(BuildContext context) async {
    final selectedImagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const ImagePickerScreen(),
      ),
    );

    return selectedImagePath ?? 'assets/images/png/puzzle_image1.png';
  }
}
