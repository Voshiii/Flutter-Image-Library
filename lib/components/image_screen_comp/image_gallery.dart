// ! DEPRICATED

// // import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:photo_album/services/fetch_service.dart';
// import 'package:photo_view/photo_view_gallery.dart';
// import 'package:photo_view/photo_view.dart';

// class MyImageGallery extends StatefulWidget {
//   final List<dynamic> images;
//   final int currentImg;
//   final String folderName;

//   const MyImageGallery({
//     super.key,
//     required this.images,
//     required this.currentImg,
//     required this.folderName,
//     });

//   @override
//   State<MyImageGallery> createState() => _MyImageGalleryState();
// }

// class _MyImageGalleryState extends State<MyImageGallery> {
//   late PageController _pageController;
//   double _verticalDrag = 0;

//   final FetchService _fetchService = FetchService();
//   // final Map<String, Uint8List?> _imageCache = {};


//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: widget.currentImg); // Initialize the controller with the starting page
//   }

//   @override
//   void dispose() {
//     _pageController.dispose(); // Dispose the controller when the widget is disposed
//     super.dispose();
//   }

//   void updateDragVal(DragUpdateDetails details){
//     _verticalDrag += details.delta.dy;
//   }

//   // Future<Uint8List?> _loadImage(int index) async {
//   Future<String?> _loadImage(int index) async {
//     final imageInfo = widget.images[index]; // Item name
//     // final key = imageInfo;

//     // if (_imageCache.containsKey(key)) {
//     //   return _imageCache[key];
//     // }

//     // final bytes = await _fetchService.fetchFile(widget.folderName, imageInfo);
//     // _imageCache[key] = bytes;
//     // return bytes;
//     final image = await _fetchService.fetchFile(widget.folderName, imageInfo);
//     return image;
//   }

//   @override
//   Widget build(BuildContext context) {

//     return GestureDetector(
//       // To-Do: Change how it closes
//       onVerticalDragUpdate: (details) {
//         updateDragVal(details);
//       },
//       onVerticalDragEnd: (details) {
//         if (_verticalDrag > 50) {
//           Navigator.pop(context); // Close on downward swipe
//         }
//         _verticalDrag = 0; // Reset
//       },
//       child: PhotoViewGallery.builder(
//       itemCount: widget.images.length,
//       pageController: _pageController,
//       scrollPhysics: const BouncingScrollPhysics(),
//       backgroundDecoration: const BoxDecoration(color: Colors.black),
//       builder: (context, index) {
//         return PhotoViewGalleryPageOptions.customChild(
//           // child: FutureBuilder<Uint8List?>(
//           child: FutureBuilder<String?>(
//             future: _loadImage(index),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasData) {
//                 // return Image.memory(snapshot.data!, fit: BoxFit.contain);
//                 return Image.network(snapshot.data!, fit: BoxFit.contain);
//               } else {
//                 return const Center(child: Text("Failed to load image", style: TextStyle(color: Colors.white)));
//               }
//             },
//           ),
//           minScale: PhotoViewComputedScale.contained,
//           maxScale: PhotoViewComputedScale.covered,
//         );
//       },
//     )


//     );
//   }
// }