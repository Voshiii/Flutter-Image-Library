import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';

class MyImageGallery extends StatefulWidget {
  final List<dynamic> images;
  final int currentImg;

  const MyImageGallery({
    super.key,
    required this.images,
    required this.currentImg,
    });

  @override
  State<MyImageGallery> createState() => _MyImageGalleryState();
}

class _MyImageGalleryState extends State<MyImageGallery> {
  late PageController _pageController;
  double _verticalDrag = 0;
  // final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentImg); // Initialize the controller with the starting page
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose the controller when the widget is disposed
    super.dispose();
  }

  void updateDragVal(DragUpdateDetails details){
    _verticalDrag += details.delta.dy;
  }


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      // To-Do: Change how it closes
      onVerticalDragUpdate: (details) {
        updateDragVal(details);
      },
      onVerticalDragEnd: (details) {
        if (_verticalDrag > 50) {
          Navigator.pop(context); // Close on downward swipe
        }
        _verticalDrag = 0; // Reset
      },
      child: PhotoViewGallery.builder(
        itemCount: widget.images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: MemoryImage(base64Decode(widget.images[index]['data'].split(',')[1])), // Uses Image.memory
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        pageController: _pageController,
      ),
    );
  }
}