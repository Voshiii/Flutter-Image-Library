// ! DEPRICATED
// ! CAN BE USED FOR FUTURE CONTENT

// // import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

// class ImageViewer extends StatefulWidget {
//   // final Uint8List img;
//   final String img;
//   final VoidCallback onTap;
//   const ImageViewer({
//     super.key, 
//     required this.img, 
//     required this.onTap
//   });

//   @override
//   ImageViewerState createState() => ImageViewerState();
// }

// class ImageViewerState extends State<ImageViewer> {
//   double _scale = 1.0;

//   void _onTapDown(TapDownDetails details) {
//     setState(() {
//       _scale = 0.8; // Shrink effect
//     });
//   }

//   void _onTapUp(TapUpDetails details) {
//     setState(() {
//       _scale = 1.0; // Restore size
//     });
//   }

//   void _onTapCancel() {
//     setState(() {
//       _scale = 1.0; // Restore size if tap is canceled
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: _onTapDown,
//       onTapUp: _onTapUp,
//       onTapCancel: _onTapCancel,
//       onTap: widget.onTap,
//       child: AnimatedScale(
//         scale: _scale,
//         duration: const Duration(milliseconds: 100),
//         curve: Curves.easeOut,
//         // child: Image.network(widget.img,),
//         child: Image.network("${dotenv.env['BASE_URL']}/uploads/SomePics/${widget.img}"),
//         // child:Image.network(
//         //   widget.img,
//         //   fit: BoxFit.cover, // crop + scale image to fill space
//         //   width: double.infinity,
//         //   height: double.infinity,
//         //   ),
//         // child: Image.memory(
//         //   widget.img,
//         //   fit: BoxFit.cover, // crop + scale image to fill space
//         //   width: double.infinity,
//         //   height: double.infinity,
//         //   ),
//       ),
//     );
//   }
// }
