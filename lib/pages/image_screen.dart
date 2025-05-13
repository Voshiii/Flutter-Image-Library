import 'package:flutter/material.dart';
import 'package:photo_album/components/image_screen_comp/empty_folder_anim.dart';
import 'package:photo_album/components/image_screen_comp/image_gallery.dart';
import 'package:photo_album/components/image_screen_comp/image_viewer.dart';
import 'package:photo_album/components/image_screen_comp/loading_anim.dart';
import 'package:photo_album/components/image_screen_comp/my_image_pop_up.dart';
import 'dart:convert';

import 'package:photo_album/components/image_screen_comp/image_selector.dart';
import 'package:photo_album/services/fetch_service.dart';

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
  final FetchService _fetchService = FetchService();
  String? username;
  String? password;


  bool _isLoading = true;

  late List<dynamic> futureImages = [];
  List<String> images = [];

  Future<void> refreshImages() async {
    if (!mounted) return;
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
    futureImages = await _fetchService.fetchImages(widget.folderName);
    if (!mounted) return;
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
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _isLoading
            ? 
            Center(
              key: ValueKey('loading'),
              child: MyLoadAnimation(),
            )
            : futureImages.isEmpty
              ? Center(child: 
                ListView(
                  key: ValueKey('empty'),
                  children: [
                    MyEmptyFolderAnim(),
                    Center(child: Text("Couldn't find any images..."))
                  ],
                )
              )
              : GridView.builder(
                  key: ValueKey('grid'),
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
                              img: base64Decode(futureImages[index]['data'].split(',')[1]),
                              imgName: futureImages[index]['name'],
                              reloadImages: refreshImages,
                            ),
                          )
                        },
                        child: ImageViewer(
                          img: base64Decode(futureImages[index]['data'].split(',')[1],), 
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => MyImageGallery(images: futureImages, current_img: index),
                            //   ),
                            // );
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => MyImageGallery(
                                  images: futureImages,
                                  currentImg: index,
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration: Duration(milliseconds: 100), // Very fast fade
                              ),
                            );
                          },
                        ),
                          
                      ),
                    );
                  },
                ),
        ),
      )
    );
  }
}