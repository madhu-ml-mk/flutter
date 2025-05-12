import 'package:flutter/material.dart';
import 'swap_puzzle.dart';
import 'slide_puzzle.dart';

class BeginnerPuzzleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Beginner Puzzle - Choose Mode")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SwapPuzzleScreen()),
                );
              },
              child: Text("Swap Puzzle"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SlidePuzzleScreen()),
                );
              },
              child: Text("Slide Puzzle"),
            ),
          ],
        ),
      ),
    );
  }
}
