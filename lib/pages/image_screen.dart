import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/empty_folder_anim.dart';
import 'package:photo_album/components/image_gallery.dart';
import 'package:photo_album/components/image_viewer.dart';
import 'package:photo_album/components/loading_anim.dart';
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
                return ClipRRect(
                  child: GestureDetector(
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
                    child: ImageViewer(
                      img: base64Decode(futureImages[index]['data'].split(',')[1],), 
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyImageGallery(images: futureImages, current_img: index),
                          ),
                        );
                      },
                    ),
                      
                  ),
                );
              },
            ),
      )
    );
  }
}