import 'package:flutter/material.dart';
import 'package:piccells/screens/image_picker_screen.dart';
import 'package:piccells/screens/slide_puzzle_screen.dart'; // Add this if not already imported

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PicCells - Choose Puzzle Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final selectedImagePath = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePickerScreen(mode: "Beginner"),
                  ),
                );

                if (selectedImagePath != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SlidePuzzleScreen(imagePath: selectedImagePath),
                    ),
                  );
                }
              },
              child: const Text("Beginner (Sliding Tile Puzzle)"),
            ),

            ElevatedButton(
              onPressed: () {
                // Direct launch with a default image
                String imagePath = "assets/images/png/puzzle_image1.png";
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SlidePuzzleScreen(imagePath: imagePath),
                  ),
                );
              },
              child: const Text("Beginner (Predefined Image)"),
            ),

            ElevatedButton(
              onPressed: () async {
                final selectedImagePath = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePickerScreen(mode: "Intermediate"),
                  ),
                );

                if (selectedImagePath != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SlidePuzzleScreen(imagePath: selectedImagePath),
                    ),
                  );
                }
              },
              child: const Text("Intermediate (Jigsaw Puzzle)"),
            ),

            ElevatedButton(
              onPressed: () async {
                final selectedImagePath = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePickerScreen(mode: "Advanced"),
                  ),
                );

                if (selectedImagePath != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SlidePuzzleScreen(imagePath: selectedImagePath),
                    ),
                  );
                }
              },
              child: const Text("Advanced (AI-Generated Puzzle)"),
            ),
          ],
        ),
      ),
    );
  }
}
