import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/folder_button.dart';
import 'package:photo_album/components/no_internet.dart';
import 'package:photo_album/components/pop_up_add_folder.dart';
import 'package:photo_album/pages/image_screen.dart';
import 'package:photo_album/pages/settings_screen.dart';
import 'package:rive/rive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:photo_album/components/folder_on_hold_popup.dart';

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

  String getParsedFolderName(String folderName){
    if (folderName.length > 15){
      return "${folderName.substring(0, 6)}...${folderName.substring(folderName.length - 5)}";
    }
    return folderName;
  }


  Widget _buildImageView() {
    OverlayEntry? overlayEntry;

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
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Center(child: Text("No folders found!")),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
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
                final parsedFolderName = getParsedFolderName(snapshot.data![index]["name"]);
                return Builder(
                  builder: (context) {
                    final layerLink = LayerLink();
                    final key = GlobalKey();

                    return GestureDetector(
                      key: key,
                      onLongPress: () {
                        final renderBox = key.currentContext!.findRenderObject() as RenderBox;
                        final position = renderBox.localToGlobal(Offset.zero);
                        final size = renderBox.size;

                        showContextMenu(context, layerLink, position, size, overlayEntry, refreshFolders, snapshot.data![index], parsedFolderName);
                      },
                      child: CompositedTransformTarget(
                        link: layerLink,
                        child: MyFolderButton(
                          folderName: parsedFolderName,
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageScreen(folderName: parsedFolderName),
                              ),
                            );
                          },
                          data: snapshot.data![index]
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
