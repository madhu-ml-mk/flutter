import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piccells/screens/image_picker_screen.dart';

class SwapPuzzleScreen extends StatefulWidget {
  final String imagePath;

  const SwapPuzzleScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _SwapPuzzleScreenState createState() => _SwapPuzzleScreenState();
}

class _SwapPuzzleScreenState extends State<SwapPuzzleScreen> {
  final int gridSize = 3;
  late double tileSize;
  late List<int> tiles;
  ui.Image? fullImage;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    _initializeTiles();
    _loadImage();
  }

  void _initializeTiles() {
    tiles = List.generate(gridSize * gridSize, (index) => index);
    tiles.shuffle();
    selectedIndex = null;
  }

  Future<void> _changeImage() async {
    final selectedImagePath = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePickerScreen(),
      ),
    );

    if (selectedImagePath != null) {
      setState(() {
        fullImage = null; // Clear the current image before loading a new one
      });
      _loadImageFromAsset(selectedImagePath);
    }
  }

Future<void> _loadImageFromAsset(String path) async {
  setState(() => fullImage = null); // Clear previous image before loading new one

  final data = await rootBundle.load(path);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final frame = await codec.getNextFrame();

  setState(() {
    fullImage = frame.image;
  });
}


  Future<void> _loadImage({XFile? imageFile}) async {
    ui.Image image;
    if (imageFile != null) {
      final data = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      image = frame.image;
    } else {
      final data = await rootBundle.load(widget.imagePath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      image = frame.image;
    }

    setState(() {
      fullImage = image;
      _initializeTiles(); // Reset puzzle when image changes
    });
  }

  void _swapTiles(int index1, int index2) {
    setState(() {
      final temp = tiles[index1];
      tiles[index1] = tiles[index2];
      tiles[index2] = temp;
      selectedIndex = null;
    });

    // Check if solved
    if (List.generate(gridSize * gridSize, (i) => i)
        .every((i) => tiles[i] == i)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎉 Puzzle Solved!")),
      );
    }
  }

  /*Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _loadImage(imageFile: pickedFile);
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;
    final boardSize = screenWidth < screenHeight ? screenWidth : screenHeight;

    tileSize = boardSize / gridSize;

    return Scaffold(
      appBar: AppBar(title: Text("Swap Puzzle")),
      body: Center(
        child: fullImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _changeImage,
                    child: Text("Change Image"),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _changeImage,
                    child: Text("Change Image"),
                  ),
                  SizedBox(height: 20),
                  Container(
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
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selectedIndex == null) {
                                selectedIndex = index;
                              } else {
                                if (selectedIndex != index) {
                                  _swapTiles(selectedIndex!, index);
                                } else {
                                  selectedIndex = null;
                                }
                              }
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: selectedIndex == index
                                      ? Colors.red
                                      : Colors.black,
                                  width: 2),
                            ),
                            child: _buildTile(tiles[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTile(int tileIndex) {
    if (fullImage == null) return Container();

    final image = fullImage!;
    final row = tileIndex ~/ gridSize;
    final col = tileIndex % gridSize;

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

    return CustomPaint(
      size: Size(tileSize, tileSize),
      painter: _TilePainter(image, src, dst),
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
