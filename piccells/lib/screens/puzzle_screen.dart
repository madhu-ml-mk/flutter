import 'package:flutter/material.dart';
import 'package:piccells/screens/beginner_puzzle.dart';
import 'package:piccells/screens/intermediate_puzzle.dart';
import 'package:piccells/screens/advanced_puzzle.dart';

class PuzzleScreen extends StatelessWidget {
  final String mode;

  PuzzleScreen({required this.mode});

  @override
  Widget build(BuildContext context) {
    Widget puzzleWidget;

    switch (mode) {
      case "Beginner":
        puzzleWidget = BeginnerPuzzleScreen();
        break;
      case "Intermediate":
        puzzleWidget = IntermediatePuzzleScreen();
        break;
      case "Advanced":
        puzzleWidget = AdvancedPuzzleScreen();
        break;
      default:
        puzzleWidget = Center(child: Text("Invalid Puzzle Mode"));
    }

    return Scaffold(
      appBar: AppBar(title: Text("$mode Mode")),
      body: puzzleWidget,
    );
  }
}
