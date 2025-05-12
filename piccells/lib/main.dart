import 'package:flutter/material.dart';
import 'package:piccells/screens/beginner_puzzle.dart';
import 'package:piccells/screens/intermediate_puzzle.dart';
import 'package:piccells/screens/advanced_puzzle.dart';
import 'package:piccells/screens/swap_puzzle.dart';


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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BeginnerPuzzleScreen())),
            child: Text("Beginner (Sliding Tile Puzzle)"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => IntermediatePuzzleScreen())),
            child: Text("Intermediate (Jigsaw Puzzle)"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdvancedPuzzleScreen())),
            child: Text("Advanced (AI-Generated Puzzle)"),
          ),
        ],
      ),
    );
  }
}
