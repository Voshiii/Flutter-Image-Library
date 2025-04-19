import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/folder_button.dart';
import 'package:photo_album/components/logout_popup.dart';
import 'package:photo_album/components/my_delete_popup.dart';
import 'package:photo_album/components/no_internet.dart';
import 'package:photo_album/components/pop_up_add_folder.dart';
import 'package:photo_album/pages/image_screen.dart';
import 'package:photo_album/pages/settings_screen.dart';
import 'package:rive/rive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key});

  @override
  State<HomeScreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2000));
  }

  Future<void> refreshFolders() async {
    setState(() {});
    hasInternet = await InternetConnection().hasInternetAccess;
  }


  Widget _buildImageView() {
    OverlayEntry? _overlayEntry;
    Offset _tapPosition = Offset.zero;

      void _showContextMenu(BuildContext context, Offset tapPosition, String folderName, LayerLink layerLink, Offset position, Size size){
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
                                refreshFolders();
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

      Overlay.of(context).insert(_overlayEntry!);
      controller.forward();
    }


    return StreamBuilder<List<dynamic>>(
      stream: _authService.getFolders(context),
      builder: (context, snapshot) {
        if(!hasInternet){
          return Column(
            children:[ SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: NoWifi(),
            ),]
          );
        }
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: RiveAnimation.asset(
              'riv_assets/fillfolder.riv',
              fit: BoxFit.contain,
            ),
          ); // Show loading animation
        } 
        else if (snapshot.hasError) {
          return Column(
            children:[ SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: NoWifi(),
            ),]
          );
        } 
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No folders found")); // Handle empty data
        }

        return Stack(
          children: [
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final folderName = snapshot.data![index];

                return Builder(
                  builder: (context) {
                    final layerLink = LayerLink();
                    final key = GlobalKey();

                    return GestureDetector(
                      key: key,
                      onTapDown: (details) => _tapPosition = details.globalPosition,
                      onLongPress: () {
                        final renderBox = key.currentContext!.findRenderObject() as RenderBox;
                        final position = renderBox.localToGlobal(Offset.zero);
                        final size = renderBox.size;

                        _showContextMenu(context, _tapPosition, folderName, layerLink, position, size);
                      },
                      child: CompositedTransformTarget(
                        link: layerLink,
                        child: MyFolderButton(
                          text: folderName,
                          backgroundColor: Color.fromARGB(255, 231, 231, 231),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageScreen(folderName: folderName),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Folders"),
        actions: [
          IconButton(
            icon: Icon(Icons.create_new_folder_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => PopUpAddFolder(),
              ).then((reload) {
                if(reload == true){
                  // Reload page after submitting
                  setState(() {});
                }
              });
            },
          ),
          IconButton(
            onPressed: () => {
              showDialog(
                context: context,
                builder: (BuildContext context) => LogoutPopup(),
              ).then((reload) {
                if(reload == true){
                  // Reload page after submitting
                  setState(() {});
                }
              })
            }, 
            icon: Icon(Icons.logout)
          ),
          IconButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MySettingsPage(),
                ),
              )
            }, 
            icon: Icon(Icons.settings)
          ),
        ],
      ),
      body: RefreshIndicator( 
        onRefresh: refreshFolders,
        child: _buildImageView()
      ),
    );
  }
}
