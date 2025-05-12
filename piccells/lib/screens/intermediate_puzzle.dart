import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jigsaw Puzzle',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const IntermediatePuzzleScreen(),
    );
  }
}

class IntermediatePuzzleScreen extends StatefulWidget {
  const IntermediatePuzzleScreen({super.key});

  @override
  State<IntermediatePuzzleScreen> createState() => _IntermediatePuzzleScreenState();
}

class _IntermediatePuzzleScreenState extends State<IntermediatePuzzleScreen> {
  final int gridSize = 3;
  final double tileSize = 100;
  late List<Offset> currentPositions;
  late List<Offset> correctPositions;
  late List<bool> isTilePlaced;
  late List<int> tileOrder;
  bool puzzleSolved = false;
  ui.Image? fullImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final data = await rootBundle.load('assets/puzzle_image3.png');
    final image = await decodeImageFromList(data.buffer.asUint8List());

    setState(() {
      fullImage = image;
      _initializePuzzle();
    });
  }

  void _initializePuzzle() {
    currentPositions = [];
    correctPositions = [];
    isTilePlaced = List.generate(gridSize * gridSize, (index) => false);

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        correctPositions.add(Offset(x * tileSize, y * tileSize));
      }
    }

    tileOrder = List.generate(gridSize * gridSize, (index) => index);
    tileOrder.shuffle();

    final random = Random();
    for (int i = 0; i < tileOrder.length; i++) {
      double x = random.nextDouble() * (tileSize * gridSize);
      double y = tileSize * gridSize + random.nextDouble() * 100 + 100;
      currentPositions.add(Offset(x, y));
    }
  }

  void _handleDragEnd(int index, DraggableDetails details) {
    if (puzzleSolved || isTilePlaced[index]) return;

    int correctIndex = tileOrder[index];
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.offset);

    final double gridLeft = (MediaQuery.of(context).size.width - gridSize * tileSize) / 2;
    final double gridTop = 100;
    final Offset target = correctPositions[correctIndex] + Offset(gridLeft, gridTop);

    bool closeEnough = (localOffset - target).distance < tileSize / 2;

    setState(() {
      if (closeEnough) {
        currentPositions[index] = target;
        isTilePlaced[index] = true;
        _checkIfSolved();
      } else {
        currentPositions[index] = Offset(localOffset.dx, localOffset.dy);
      }
    });
  }

  void _checkIfSolved() {
    if (isTilePlaced.every((placed) => placed)) {
      setState(() {
        puzzleSolved = true;
      });
    }
  }

  void _resetPuzzle() {
    setState(() {
      puzzleSolved = false;
      _initializePuzzle();
    });
  }

  Widget _buildDraggableTile(int index) {
    return Positioned(
      left: currentPositions[index].dx,
      top: currentPositions[index].dy,
      child: isTilePlaced[index]
          ? _buildTile(index)
          : Draggable<int>(
              data: index,
              feedback: _buildTile(index, isDragging: true),
              childWhenDragging: const SizedBox.shrink(),
              onDragEnd: (details) => _handleDragEnd(index, details),
              child: _buildTile(index),
            ),
    );
  }

  Widget _buildTile(int index, {bool isDragging = false}) {
    int imageIndex = tileOrder[index];
    int x = imageIndex % gridSize;
    int y = imageIndex ~/ gridSize;

    return ClipRect(
      child: Container(
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
        child: fullImage == null
            ? const SizedBox.shrink()
            : CustomPaint(
                size: Size(tileSize, tileSize),
                painter: _ImageTilePainter(
                  image: fullImage!,
                  tileX: x,
                  tileY: y,
                  gridSize: gridSize,
                  isDragging: isDragging,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gridWidth = tileSize * gridSize;
    final double gridLeft = (MediaQuery.of(context).size.width - gridWidth) / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jigsaw Puzzle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetPuzzle,
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            left: gridLeft,
            child: SizedBox(
              width: gridWidth,
              height: gridWidth,
              child: Stack(
                children: List.generate(
                  gridSize * gridSize,
                  (index) => Positioned(
                    left: correctPositions[index].dx,
                    top: correctPositions[index].dy,
                    child: Container(
                      width: tileSize,
                      height: tileSize,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ...List.generate(tileOrder.length, (index) => _buildDraggableTile(index)),
          if (puzzleSolved)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white70,
                child: const Text(
                  'Puzzle Solved! ??',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageTilePainter extends CustomPainter {
  final ui.Image image;
  final int tileX;
  final int tileY;
  final int gridSize;
  final bool isDragging;

  _ImageTilePainter({
    required this.image,
    required this.tileX,
    required this.tileY,
    required this.gridSize,
    this.isDragging = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      tileX * image.width / gridSize,
      tileY * image.height / gridSize,
      image.width / gridSize,
      image.height / gridSize,
    );

    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
