import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/save_image.dart';
import 'package:photo_album/cache/file_data_cache.dart';
import 'package:photo_album/components/home_page_comp/info_modal.dart';
import 'package:photo_album/components/home_page_comp/my_delete_popup.dart';
import 'package:photo_album/components/home_page_comp/rename_item_dialog.dart';
import 'package:photo_album/services/fetch_service.dart';
import 'package:photo_album/services/share_img.dart';

void showContextMenu(BuildContext context, 
    LayerLink layerLink, 
    Offset position, // location of the button
    Size size, // button size
    OverlayEntry? overlayEntry,
    Future<void> Function()? onRefresh,
    dynamic data,
    String parsedFileName, // File name (e.g. imag...e.jpg)
    String currentFolderPath, // the current folderPath (e.g. username/newFolder)
    String fullFileName, // Full file name (e.g. imag123e.jpg)
    bool isFile, // Bool if item is a file or folder
    Widget dataButtonWidget // Used to bring the button to the front when long clicking
  ){
    print("THE DATA IS: $data");
    final screenSize = MediaQuery.of(context).size;
    final FetchService fetchService = FetchService();

    // Safe margin
    final popupWidth = 160.0;
    final popupHeight = 320.0;

    // Clamp the position to keep the popup on-screen
    double dx = position.dx;
    double dy = position.dy+130;
    // double dy = position.dy;

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

    Future<String> getImageBytes() async {
      return FileCacheHelper.getFileData(data["name"], currentFolderPath).toString();
    }

    final AnimationController controller = AnimationController(
      vsync: Navigator.of(context),
      duration: Duration(milliseconds: 200),
    );
    final Animation<double> scale = CurvedAnimation(parent: controller, curve: Curves.easeOutBack);

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Background blur
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Color.fromRGBO(0, 0, 0, 0.3)),
              ),
            ),

            // Tap anywhere to dismiss
            Positioned.fill(
              child: GestureDetector(
                onTap: () async {
                  await controller.reverse();
                  overlayEntry?.remove();
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
                    width: size.width,
                    height: size.height,
                    child: 
                    dataButtonWidget
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
                            
                            // TODO Copy items [NOT IMPLEMENTED]
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
                            
                            // TODO Share items [NEEDS TO BE FIXED]
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  List<dynamic> folderImages = await fetchService.fetchAllFiles(data["name"]);
                                  List<Uint8List> savedImages = [];
                                  for (var i = 0; i < folderImages.length; i++){
                                    savedImages.add(base64Decode(folderImages[i]['data'].split(',')[1]));
                                  }
                                  if (savedImages.isNotEmpty) shareImages(savedImages);
                                  await controller.reverse();
                                  overlayEntry?.remove();
                                  if (savedImages.isEmpty){
                                    if(!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error occured!')),
                                    );
                                  }
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

                            // TODO Download [NOT IMPLEMENTED]
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // String bytes = getImageBytes();
                                  // saveImageToGallery(bytes);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Column(
                                  children: [
                                    Icon(Icons.download),
                                    Text(
                                      "Download",
                                      style: TextStyle(fontSize: 10),
                                    )
                                  ],
                                ),
                              ),
                            ),

                          ],),
                        ),
                        Divider(height: 1, thickness: 1, color: Colors.grey,),
                        
                        // TODO Get info from item [only works with folder for now]
                        ListTile(
                          title: Row(
                            children: [
                              Text("Get info"),
                              Spacer(),
                              Icon(Icons.info_outline)
                            ],
                          ),
                          onTap: () async {
                            await controller.reverse(); // play animation when closing
                            overlayEntry?.remove();
                            if(!context.mounted) return;
                            showInfoModal(context, data, isFile);
                          },
                        ),
                        Divider(height: 1, thickness: 1, color: Colors.grey,),
                        
                        // Rename item
                        ListTile(
                          title: Row(children: [
                            Text("Rename"),
                            Spacer(),
                            Icon(Icons.drive_file_rename_outline)
                          ],),
                          onTap: () async {
                            await controller.reverse(); // play animation when closing
                            overlayEntry?.remove();
                            
                            if(!context.mounted) return;
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => PopUpRenameItem(oldFolderName: data["name"], currentFolderPath: currentFolderPath, isFile: isFile,),
                            );

                            if (result == true) {
                              await onRefresh?.call();
                            }

                          },
                        ),
                        Divider(height: 1, thickness: 1, color: Colors.grey,),

                        // TODO Favorite [NOT IMPLEMENTED YET]
                        ListTile(
                          title: Row(children: [
                            Text("Favorite"),
                            Spacer(),
                            Icon(Icons.star_border_outlined)
                          ],)
                        ),
                        Divider(height: 1, thickness: 1, color: Colors.grey,),
                        
                        // Delete item
                        ListTile(
                          title: Row(children: [
                            Text("Delete",
                            style: TextStyle(color: Colors.red)),
                            Spacer(),
                            Icon(Icons.delete, color: Colors.red,)
                          ],),
                          onTap: () async {
                            await controller.reverse(); // play animation when closing
                            overlayEntry?.remove();
                            if(!context.mounted) return;
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => MyDeleteDialog(
                                fileName: fullFileName, filePath: currentFolderPath,
                              ),
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

    Overlay.of(context).insert(overlayEntry);
    controller.forward();
}