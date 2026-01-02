import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/cache/file_data_cache.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<dynamic> files;
  final String folderPath;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.files,
    required this.folderPath,
    required this.initialIndex
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  // Uint8List decodedBytes = Uint8List(0);
  late ExtendedPageController _controller;
  List<Uint8List?> decodedList = [];

  @override
  void initState() {
    super.initState();

    _controller = ExtendedPageController(initialPage: widget.initialIndex);

    loadAllFiles();
  }

  Future<void> loadAllFiles() async {
    for (var file in widget.files) {
      if (isFile(file)) {
        decodedList.add(await FileCacheHelper.getFileData(file, widget.folderPath));
      }
    }
    print(decodedList.length);
    setState(() {});
  }

  bool isFile(String name) => name.contains('.') && !name.startsWith('.');

  @override
  Widget build(BuildContext context) {
    if (decodedList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
    backgroundColor: Colors.black,
      body: Stack(
        children: [
          // The gallery behind
          ExtendedImageGesturePageView.builder(
            controller: _controller,
            itemCount: decodedList.length,
            itemBuilder: (context, index) {
              final bytes = decodedList[index];
              return ExtendedImage.memory(
                bytes!,
                fit: BoxFit.contain,
                mode: ExtendedImageMode.gesture,
              );
            },
          ),

          // Back button on top
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}