import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_album/components/folder_button.dart';
import 'package:photo_album/components/my_delete_popup.dart';
import 'package:photo_album/pages/image_screen.dart';

void showContextMenu(BuildContext context, 
    String folderName, 
    LayerLink layerLink, 
    Offset position, 
    Size size, 
    OverlayEntry? _overlayEntry,
    Future<void> Function()? onRefresh
  ){
  final screenSize = MediaQuery.of(context).size;

  // Safe margin
  final popupWidth = 160.0;
  final popupHeight = 250.0;

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
    dy -= 380;
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
              onTap: () {
                controller.dispose();
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
                    text: folderName,
                    backgroundColor: Color.fromARGB(0, 0, 0, 0),
                    onTap: () {
                      controller.dispose();
                      _overlayEntry?.remove();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageScreen(folderName: folderName),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Row(children: [
                          Text("Get info"),
                          Spacer(),
                          Icon(Icons.info_outline)
                        ],)
                      ),
                      Divider(height: 1, thickness: 1, color: Colors.grey,),
                      ListTile(
                        title: Row(children: [
                          Text("Rename"),
                          Spacer(),
                          Icon(Icons.drive_file_rename_outline)
                        ],)
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
                          controller.dispose();
                          _overlayEntry?.remove();
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) => MyDeleteDialog(folderName: folderName),
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