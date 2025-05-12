import 'package:flutter/material.dart';
import 'package:piccells/screens/puzzle_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PicCells - Choose Puzzle Mode")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PuzzleScreen(mode: "Beginner"))),
            child: Text("Beginner (Sliding Tile Puzzle)"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PuzzleScreen(mode: "Intermediate"))),
            child: Text("Intermediate (Jigsaw Puzzle)"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PuzzleScreen(mode: "Advanced"))),
            child: Text("Advanced (AI-Generated Puzzle)"),
          ),
        ],
      ),
    );
  }
}
