// ! Decricated
// ! Might still use some components

// import 'package:flutter/material.dart';
// import 'package:photo_album/components/image_screen_comp/add_options.dart';
// import 'package:photo_album/components/image_screen_comp/empty_folder_anim.dart';
// import 'package:photo_album/components/image_screen_comp/image_gallery.dart';
// import 'package:photo_album/components/image_screen_comp/image_viewer.dart';
// import 'package:photo_album/components/image_screen_comp/loading_anim.dart';
// import 'package:photo_album/components/image_screen_comp/my_image_pop_up.dart';
// import 'package:photo_album/services/fetch_service.dart';

// class ImageScreen extends StatefulWidget {
//   final String folderName;
//   const ImageScreen({
//     super.key,
//     required this.folderName,
//   });

//   @override
//   State<ImageScreen> createState() => _ImageScreenState();
// }

// class _ImageScreenState extends State<ImageScreen>  with SingleTickerProviderStateMixin {
//   final FetchService _fetchService = FetchService();
//   String? username;
//   String? password;

//   double _scale = 1.0;                 // Current zoom scale factor
//   int _crossAxisCount = 2;             // Current grid column count
//   final int minCrossAxisCount = 2;     // Minimum columns
//   final int maxCrossAxisCount = 6;     // Maximum columns

//   bool _isLoading = true;

//   late List<dynamic> futureImages = [];
//   List<String> images = [];

//   Future<void> refreshImages() async {
//     if (!mounted) return;
//     setState(() {
//       _loadFileNames();
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _loadFileNames();
//   }

//   void _loadFileNames() async {
//     // futureImages = await _fetchService.fetchFileNames(widget.folderName);

//     if (!mounted) return;
//     setState(() {}); // Trigger a rebuild with the new data
//     _isLoading = false;
//   }

//   final GlobalKey _buttonKey = GlobalKey();

//   void _showOptionsMenu() {
//     final RenderBox button = _buttonKey.currentContext!.findRenderObject() as RenderBox;
//     final Offset offset = button.localToGlobal(Offset.zero);
//     final Size size = button.size;

//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: "Dismiss",
//       barrierColor: Colors.black12,
//       pageBuilder: (_, __, ___) => const SizedBox.shrink(), // Required
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         return FadeTransition(
//           opacity: animation,
//           child: Stack(
//             children: [
//               Positioned(
//                 top: offset.dy + size.height + 8,
//                 right: 16,
//                 child: IOSPopupMenu(
//                   onSelect: (value) {
//                     // Navigator.pop(context);
//                     print("Selected: $value");
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//       transitionDuration: const Duration(milliseconds: 150),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.folderName),
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.add_circle_outline_rounded,
//               size: 40,
//               color: const Color.fromARGB(255, 2, 86, 155),
//             ),
//             key: _buttonKey,
//             onPressed: () {
//               _showOptionsMenu();
//             },
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: refreshImages,
//         child: AnimatedSwitcher(
//           duration: Duration(milliseconds: 400),
//           switchInCurve: Curves.easeOut,
//           switchOutCurve: Curves.easeIn,
//           child: _isLoading
//             ? 
//             Center(
//               key: ValueKey('loading'),
//               child: MyLoadAnimation(),
//             )
//             : futureImages.isEmpty
//               ? Center(child: 
//                 ListView(
//                   key: ValueKey('empty'),
//                   children: [
//                     MyEmptyFolderAnim(),
//                     Center(child: Text("Couldn't find any images..."))
//                   ],
//                 )
//               )
//               : GestureDetector(
//                   onScaleUpdate: (details) {
//                     setState(() {
//                       // Update the scale with the relative scale from gesture, clamp so it stays reasonable
//                       final double zoomSensitivity = 0.3;  // smaller value = slower zoom
//                       _scale = (_scale * (1 + (details.scale - 1) * zoomSensitivity)).clamp(0.5, 3.0);
      
//                       // Calculate new crossAxisCount inversely proportional to _scale
//                       int newCount = (3 / _scale).round();
      
//                       // Clamp to min/max
//                       newCount = newCount.clamp(minCrossAxisCount, maxCrossAxisCount);
      
//                       if (newCount != _crossAxisCount) {
//                         _crossAxisCount = newCount;
//                       }
//                     });
//                   },
//                   onScaleStart: (_) {
//                     // Optionally reset or handle scale start
//                     // _scale = 1.0;
//                   },
//                 child: GridView.builder(
//                     key: ValueKey('grid'),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: _crossAxisCount,
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                     ),
//                     padding: EdgeInsets.only(left: 12, right: 12),
//                     itemCount: futureImages.length,
//                     itemBuilder: (context, index) {
//                       // return FutureBuilder<Uint8List?>(
//                       return FutureBuilder<String?>(
//                         future: _fetchService.fetchFile(widget.folderName, futureImages[index]),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return const Center(child: CircularProgressIndicator());
//                           } else if (snapshot.hasError || snapshot.data == null) {
//                             return const Center(child: Icon(Icons.broken_image));
//                           }
      
//                           return ClipRRect(
//                             child: GestureDetector(
//                               onLongPress: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) => MyImagePopUp(
//                                     folderName: widget.folderName,
//                                     img: snapshot.data!,
//                                     imgName: futureImages[index],
//                                     reloadImages: refreshImages,
//                                   ),
//                                 );
//                               },
//                               child: ImageViewer(
//                                 // img: snapshot.data!,
//                                 img: snapshot.data!,
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     PageRouteBuilder(
//                                       pageBuilder: (context, animation, secondaryAnimation) =>
//                                           MyImageGallery(
//                                         images: futureImages,
//                                         currentImg: index,
//                                         folderName: widget.folderName,
//                                       ),
//                                       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                                         return FadeTransition(opacity: animation, child: child);
//                                       },
//                                       transitionDuration: const Duration(milliseconds: 100),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//               ),
//         ),
//       )
//     );
//   }
// }