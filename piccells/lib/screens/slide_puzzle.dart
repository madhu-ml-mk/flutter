import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class SlidePuzzleScreen extends StatefulWidget {
  @override
  _SlidePuzzleScreenState createState() => _SlidePuzzleScreenState();
}

class _SlidePuzzleScreenState extends State<SlidePuzzleScreen> {
  final int gridSize = 3;
  late double tileSize;
  late List<int> tiles;
  ui.Image? fullImage;

  @override
  void initState() {
    super.initState();
    _initializeTiles();
    _loadImage();
  }

  void _initializeTiles() {
    tiles = List.generate(gridSize * gridSize, (i) => i);
    tiles.shuffle();
  }

  Future<void> _loadImage() async {
    final data = await rootBundle.load('assets/puzzle_image3.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    setState(() {
      fullImage = frame.image;
    });
  }

  void _swapTiles(int fromIndex, int toIndex) {
    setState(() {
      final temp = tiles[fromIndex];
      tiles[fromIndex] = tiles[toIndex];
      tiles[toIndex] = temp;
    });

    if (List.generate(gridSize * gridSize, (i) => i)
        .every((i) => tiles[i] == i)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎉 Puzzle Solved!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;
    final boardSize = screenWidth < screenHeight ? screenWidth : screenHeight;

    tileSize = boardSize / gridSize;

    return Scaffold(
      appBar: AppBar(title: Text("Slide Puzzle")),
      body: Center(
        child: fullImage == null
            ? CircularProgressIndicator()
            : Container(
                width: tileSize * gridSize,
                height: tileSize * gridSize,
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    return _buildDraggableTile(index);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildDraggableTile(int index) {
    final tileIndex = tiles[index];
    final row = tileIndex ~/ gridSize;
    final col = tileIndex % gridSize;

    return DragTarget<int>(
      onAccept: (fromIndex) => _swapTiles(fromIndex, index),
      builder: (context, candidateData, rejectedData) {
        return Draggable<int>(
          data: index,
          feedback: Opacity(
            opacity: 0.8,
            child: _buildTile(row, col),
          ),
          childWhenDragging: Container(
            color: Colors.grey[300],
          ),
          child: _buildTile(row, col),
        );
      },
    );
  }

  Widget _buildTile(int row, int col) {
    if (fullImage == null) return Container();

    final image = fullImage!;
    final imageWidth = image.width;
    final imageHeight = image.height;

    final tileWidth = imageWidth ~/ gridSize;
    final tileHeight = imageHeight ~/ gridSize;

    final src = Rect.fromLTWH(
      col * tileWidth.toDouble(),
      row * tileHeight.toDouble(),
      tileWidth.toDouble(),
      tileHeight.toDouble(),
    );

    final dst = Rect.fromLTWH(0, 0, tileSize, tileSize);

    return Container(
      margin: EdgeInsets.all(2),
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: CustomPaint(
        size: Size(tileSize, tileSize),
        painter: _TilePainter(image, src, dst),
      ),
    );
  }
}

class _TilePainter extends CustomPainter {
  final ui.Image image;
  final Rect src;
  final Rect dst;

  _TilePainter(this.image, this.src, this.dst);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
