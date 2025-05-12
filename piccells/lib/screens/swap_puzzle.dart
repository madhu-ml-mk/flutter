import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class SwapPuzzleScreen extends StatefulWidget {
  @override
  _SwapPuzzleScreenState createState() => _SwapPuzzleScreenState();
}

class _SwapPuzzleScreenState extends State<SwapPuzzleScreen> {
  final int gridSize = 3;
  late List<int> tiles;
  int? firstSelected;
  ui.Image? fullImage;
  late double tileSize;

  @override
  void initState() {
    super.initState();
    _initializeTiles();
    _loadImage();
  }

  void _initializeTiles() {
    tiles = List.generate(gridSize * gridSize, (index) => index);
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

  void swapTiles(int index1, int index2) {
    setState(() {
      final temp = tiles[index1];
      tiles[index1] = tiles[index2];
      tiles[index2] = temp;
      firstSelected = null;
    });
    _checkWinCondition();
  }

  void _checkWinCondition() {
    if (List.generate(gridSize * gridSize, (i) => i)
        .every((i) => tiles[i] == i)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎉 Puzzle Solved!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Swap Puzzle")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Take the smaller of width or height for square layout
          final availableSize = constraints.biggest.shortestSide;
          tileSize = availableSize / gridSize;

          return Center(
            child: fullImage == null
                ? CircularProgressIndicator()
                : SizedBox(
                    width: tileSize * gridSize,
                    height: tileSize * gridSize,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        childAspectRatio: 1,
                      ),
                      itemCount: gridSize * gridSize,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (firstSelected == null) {
                              setState(() => firstSelected = index);
                            } else {
                              swapTiles(firstSelected!, index);
                            }
                          },
                          child: _buildTile(index),
                        );
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }


  Widget _buildTile(int index) {
    final tileIndex = tiles[index];
    final row = tileIndex ~/ gridSize;
    final col = tileIndex % gridSize;

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
      decoration: BoxDecoration(
        border: Border.all(
          color: (index == firstSelected) ? Colors.red : Colors.black,
          width: 2,
        ),
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
