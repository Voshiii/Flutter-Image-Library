import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/folder_button.dart';
import 'package:photo_album/components/info_modal.dart';
import 'package:photo_album/components/my_delete_popup.dart';
import 'package:photo_album/components/rename_folder_dialog.dart';
import 'package:photo_album/pages/image_screen.dart';
import 'package:photo_album/services/share_img.dart';


void showContextMenu(BuildContext context, 
    LayerLink layerLink, 
    Offset position, 
    Size size, 
    OverlayEntry? _overlayEntry,
    Future<void> Function()? onRefresh,
    dynamic data,
    String parsedFolderName,
  ){
  final screenSize = MediaQuery.of(context).size;
  final AuthService _authService = AuthService();

  // Safe margin
  final popupWidth = 160.0;
  final popupHeight = 320.0;

  // Clamp the position to keep the popup on-screen
  double dx = position.dx;
  double dy = position.dy+130;

  // When popup goes over screen width
  if (dx + popupWidth > screenSize.width) {
    dx -= 90;
  }

  // When popup goes over screen width (on the left)
  if(dx - popupWidth < 0){
    dx += 20;
  }

  // When popup goes over screen height (bottom)
  if (dy + popupHeight > screenSize.height) {
    dy -= 430;
  }

  final AnimationController controller = AnimationController(
    vsync: Navigator.of(context),
    duration: Duration(milliseconds: 200),
  );
  final Animation<double> scale = CurvedAnimation(parent: controller, curve: Curves.easeOutBack);

  _overlayEntry = OverlayEntry(
    builder: (context) {
      return Stack(
        children: [
          // Background blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),

          // Tap anywhere to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: () async {
                await controller.reverse();
                _overlayEntry?.remove();
              },
              child: Container(color: Colors.transparent),
            ),
          ),

          // Bring tapped widget to front (not blurred)
          CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topLeft,
            followerAnchor: Alignment.topLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: MyFolderButton(
                    folderName: parsedFolderName,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    data: data,
                    onTap: () {
                      controller.dispose();
                      _overlayEntry?.remove();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageScreen(folderName: parsedFolderName),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),


          // Popup
          Positioned(
            left: dx + size.width / 2 - 80,
            top: dy,
            child: ScaleTransition(
              scale: scale,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: popupWidth + 70,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withAlpha(197),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 5,),
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                children: [
                                  Icon(Icons.folder_copy), // MAYBE REMOVE COPY
                                  Text(
                                    "Copy",
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              ),
                            ),
                          ),
                          
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                List<dynamic> folderImages = await _authService.fetchImages(data["name"]);
                                List<Uint8List> savedImages = [];
                                for (var i = 0; i < folderImages.length; i++){
                                  savedImages.add(base64Decode(folderImages[i]['data'].split(',')[1]));
                                }
                                if (savedImages.isNotEmpty) shareImages(savedImages);
                                await controller.reverse();
                                _overlayEntry?.remove();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Folder is empty!')),
                                );
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                children: [
                                  Icon(Icons.ios_share),
                                  Text(
                                    "Share",
                                    style: TextStyle(fontSize: 10),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],),
                      ),
                      Divider(height: 1, thickness: 1, color: Colors.grey,),
                      ListTile(
                        title: Row(children: [
                          Text("Get info"),
                          Spacer(),
                          Icon(Icons.info_outline)
                        ],),
                        onTap: () async {
                          await controller.reverse();
                          _overlayEntry?.remove();
                          showInfoModal(context, data);
                        },
                      ),
                      Divider(height: 1, thickness: 1, color: Colors.grey,),
                      ListTile(
                        title: Row(children: [
                          Text("Rename"),
                          Spacer(),
                          Icon(Icons.drive_file_rename_outline)
                        ],),
                        onTap: () async {
                          await controller.reverse();
                          _overlayEntry?.remove();
                          
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) => PopUpRenameFolder(oldFolderName: data["name"]),
                          );

                          if (result == true) {
                            await onRefresh?.call();
                          }

                        },
                      ),
                      Divider(height: 1, thickness: 1, color: Colors.grey,),
                      ListTile(
                        title: Row(children: [
                          Text("Favorite"),
                          Spacer(),
                          Icon(Icons.star_border_outlined)
                        ],)
                      ),
                      Divider(height: 1, thickness: 1, color: Colors.grey,),
                      ListTile(
                        title: Row(children: [
                          Text("Delete",
                          style: TextStyle(color: Colors.red)),
                          Spacer(),
                          Icon(Icons.delete, color: Colors.red,)
                        ],),
                        onTap: () async {
                          await controller.reverse();
                          _overlayEntry?.remove();
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) => MyDeleteDialog(folderName: data["name"]),
                          );

                          if (result == true) {
                            await onRefresh?.call();
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  Overlay.of(context).insert(_overlayEntry);
  controller.forward();
}