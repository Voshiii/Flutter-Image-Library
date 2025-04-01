import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/empty_folder_anim.dart';
import 'package:photo_album/components/image_viewer.dart';
import 'package:photo_album/components/loading_anim.dart';
// import 'package:photo_album/components/my_delete_popup.dart';
import 'package:photo_album/components/my_image_pop_up.dart';
import 'dart:convert';

import 'package:photo_album/components/pop_up_text.dart';

class ImageScreen extends StatefulWidget {
  final String folderName;
  const ImageScreen({
    super.key,
    required this.folderName,
  });

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final AuthService _authService = AuthService();
  String? username;
  String? password;


  bool _isLoading = true;

  late List<dynamic> futureImages = [];
  List<String> images = [];

  Future<void> refreshImages() async {
    setState(() {
      _loadImages();
    });
  }

    // Decode the base64 image string once
  // Future<Uint8List> _decodeImage(String base64Image) async {
  //   return base64Decode(base64Image.split(',')[1]);
  // }

  //UPDATED:
  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() async {
    futureImages = await _authService.fetchImages(widget.folderName);
    setState(() {}); // Trigger a rebuild with the new data
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              size: 40,
              color: const Color.fromARGB(255, 2, 86, 155),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => ImageSelectorDialog(folderName: widget.folderName),
              ).then((reload) {
                if(reload == true){
                  _loadImages();
                }
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator( 
        onRefresh: refreshImages,
        child: _isLoading
        ? Center(
            child: MyLoadAnimation(),
          )
        : futureImages.isEmpty
          ? Center(child: 
            ListView(
              children: [
                MyEmptyFolderAnim(),
                Center(child: Text("Couldn't find any images..."))
              ],
            )
          )
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: EdgeInsets.only(left: 12, right: 12),
              itemCount: futureImages.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  // onTapDown: _onTapDown,
                  // onTapUp: _onTapUp,
                  // onTapCancel: _onTapCancel,
                  onLongPress: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => MyImagePopUp(
                        folderName: widget.folderName,
                        // img: futureImages[index]['data'].split(',')[1],
                        img: base64Decode(futureImages[index]['data'].split(',')[1]),
                        imgName: futureImages[index]['name'],
                      ),
                      ).then((reload) {
                        // Reload page after submitting
                        if(reload == true){
                          refreshImages();
                          // setState(() {});
                        }
                      })
                  },
                  child: ImageViewer(imageData: base64Decode(futureImages[index]['data'].split(',')[1])),
                  // FIX FLICKERING
                  // child: FutureBuilder<Uint8List>(
                  //   future: _decodeImage(futureImages[index]['data']), // Only decode once
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return CircularProgressIndicator(); // Show loading spinner while waiting
                  //     } else if (snapshot.hasError) {
                  //       return Icon(Icons.error); // Show error icon if something goes wrong
                  //     } else if (snapshot.hasData) {
                  //       // return AnimatedScale(
                  //       //   scale: _scale,
                  //       //   duration: const Duration(milliseconds: 100),
                  //       //   child: Image.memory(snapshot.data!),
                  //       // );
                  //       return ImageViewer(imageData: snapshot.data!);
                  //     }
                  //     return SizedBox(); // In case of an unexpected error
                  //   },
                  // )
                );
              },
            ),
      )
    );
  }
}