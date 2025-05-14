import 'package:flutter/material.dart';
import 'package:piccells/screens/beginner_puzzle.dart';
import 'package:piccells/screens/intermediate_puzzle.dart';
import 'package:piccells/screens/advanced_puzzle.dart';
import 'package:piccells/screens/image_picker_screen.dart';


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ModeSelectionScreen(),
  ));
}

class ModeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PicCells - Choose Puzzle Mode")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BeginnerPuzzleScreen(),
              ),
            ),
            child: Text("Beginner (Sliding Tile Puzzle)"),
          ),
          ElevatedButton(
            onPressed: () async {
              String imagePath = await _selectImage(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IntermediatePuzzleScreen(imagePath: imagePath),
                ),
              );
            },
            child: Text("Intermediate (Jigsaw Puzzle)"),
          ),
          ElevatedButton(
            onPressed: () async {
              String imagePath = await _selectImage(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdvancedPuzzleScreen(imagePath: imagePath),
                ),
              );
            },
            child: Text("Advanced (AI-Generated Puzzle)"),
          ),
        ],
      ),
    );
  }

  // Simulate the image selection process
 Future<String> _selectImage(BuildContext context) async {
   final selectedImagePath = await Navigator.push<String>(
     context,
     MaterialPageRoute(
       builder: (context) => ImagePickerScreen(),
     ),
   );

   return selectedImagePath ?? 'assets/images/png/puzzle_image1.png'; // fallback
 }

}
