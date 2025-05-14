import 'package:flutter/material.dart';
import 'dart:math';

class AdvancedPuzzleScreen extends StatefulWidget {
  final String imagePath;

  const AdvancedPuzzleScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _AdvancedPuzzleScreenState createState() => _AdvancedPuzzleScreenState();
}

class _AdvancedPuzzleScreenState extends State<AdvancedPuzzleScreen> {
  List<Map<String, dynamic>> tiles = [];

  Future<void> generateAITiles() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate AI processing
    setState(() {
      tiles = List.generate(6, (index) => {
        "imagePath": widget.imagePath, // Use provided image path
        "x": Random().nextInt(300).toDouble(),
        "y": Random().nextInt(400).toDouble(),
      });
    });
  }

  @override
  void initState() {
    super.initState();
    generateAITiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Advanced - AI Puzzle")),
      body: Stack(
        children: tiles.map((tile) => Positioned(
          top: tile["y"],
          left: tile["x"],
          child: Image.asset(tile["imagePath"]),
        )).toList(),
      ),
    );
  }
}
