import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piccells/screens/image_picker_screen.dart';


class IntermediatePuzzleScreen extends StatefulWidget {
  final String? imagePath;
  const IntermediatePuzzleScreen({Key? key, this.imagePath}) : super(key: key);

  @override
  _IntermediatePuzzleScreenState createState() => _IntermediatePuzzleScreenState();
}

class _IntermediatePuzzleScreenState extends State<IntermediatePuzzleScreen> {
  final int gridSize = 4;
  double tileSize = 100;
  late List<Offset> currentPositions;
  late List<Offset> correctPositions;
  late List<bool> isTilePlaced;
  late List<int> tileOrder;
  bool puzzleSolved = false;
  ui.Image? fullImage;
  File? selectedImageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.imagePath != null) {
        _loadImageFromAsset(widget.imagePath!);
      }
    });
  }

  Future<void> _loadImageFromAsset(String path) async {
    setState(() => isLoading = true);
    final data = await rootBundle.load(path);
    final image = await decodeImageFromList(data.buffer.asUint8List());
    setState(() {
      fullImage = image;
      selectedImageFile = null;
      isLoading = false;
    });
    _initializePuzzle();
  }

  Future<void> _loadImageFromFile(File imageFile) async {
    setState(() => isLoading = true);
    try {
      final imageData = await imageFile.readAsBytes();
      final image = await decodeImageFromList(imageData);
      setState(() {
        fullImage = image;
        selectedImageFile = imageFile;
        isLoading = false;
      });
      _initializePuzzle();
    } catch (e) {
      debugPrint('Error loading image: $e');
      setState(() => isLoading = false);
    }
  }

  void _initializePuzzle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxTileSize = min((screenWidth - 40) / gridSize, (screenHeight - 300) / gridSize);
    tileSize = maxTileSize;

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

    final double heapTop = 100 + tileSize * gridSize + 30;
    final double heapHeight = MediaQuery.of(context).size.height - heapTop - tileSize;
    final double heapWidth = MediaQuery.of(context).size.width - tileSize;
    final random = Random();

    for (int i = 0; i < tileOrder.length; i++) {
      double x = random.nextDouble() * heapWidth;
      double y = heapTop + random.nextDouble() * max(50, heapHeight);
      currentPositions.add(Offset(x, y));
    }

    puzzleSolved = false;
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
    if (selectedImageFile != null) {
      _loadImageFromFile(selectedImageFile!);
    } else if (widget.imagePath != null) {
      _loadImageFromAsset(widget.imagePath!);
    }
  }

Future<void> _changeImage() async {
  final selectedImagePath = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ImagePickerScreen(),
    ),
  );

  if (selectedImagePath != null) {
    _loadImageFromAsset(selectedImagePath);
  }
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
        title: const Text('Intermediate Puzzle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _changeImage,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetPuzzle,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
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
                        'Puzzle Solved!',
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