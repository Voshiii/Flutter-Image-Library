import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide LinearGradient;
import 'package:photo_album/animations/loading_anim.dart';
// import 'package:photo_album/animations/empty_folder_anim.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/home_page_comp/data_grid.dart';
import 'package:photo_album/components/home_page_comp/no_internet.dart';
import 'package:photo_album/components/home_page_comp/pop_up_add_folder.dart';
import 'package:photo_album/components/home_page_comp/add_options.dart';
import 'package:photo_album/components/home_page_comp/file_selector.dart';
import 'package:photo_album/pages/settings_screen.dart';
import 'package:photo_album/services/fetch_service.dart';

// This class (or a class that this class inherits from) is marked as 
//'@immutable', but one or more of its instance fields aren't final: 
//HomeScreen.folderStream
// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  late Stream<Map<String, dynamic>> fileStream;
  final String currentFolderPath; // full folderpath including name

  HomeScreen({
    super.key,
    required this.fileStream,
    required this.currentFolderPath
  });

  @override
  State<HomeScreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<HomeScreen> {
  final FetchService _fetchService = FetchService();
  bool hasInternet = true;

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> allFiles = [];

  final GlobalKey _buttonKey = GlobalKey();

  Stream<Map<String, dynamic>>? currentWindowFileStream;

  @override
  void initState() {
    super.initState();
    currentWindowFileStream = widget.fileStream;
  }


  void _showOptionsMenu() {
    final RenderBox button = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    final Size size = button.size;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black12,
      pageBuilder: (_, __, ___) => const SizedBox.shrink(), // Required
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: Stack(
            children: [
              Positioned(
                top: offset.dy + size.height + 8,
                right: 16,
                child: IOSPopupMenu( // The 'add' button will give 3 options
                  onSelect: (value) {
                    switch (value) {
                      case "Upload from Files":
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => FileSelectorDialog(folderPath: widget.currentFolderPath, fromGallery: false)
                        ).then((reload) {
                          if(reload == true){refreshFiles();}
                        });
                        break;
                      case "Upload from Gallery":
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => FileSelectorDialog(folderPath: widget.currentFolderPath, fromGallery: true)
                        ).then((reload) {
                          if(reload == true){refreshFiles();}
                        });
                        break;
                      case "New Folder":
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => PopUpAddFolder(currentFolderPath: widget.currentFolderPath,),
                        ).then((reload) {
                          if(reload == true){
                            refreshFiles();
                          }
                        });
                        break;
                      default:
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> refreshFiles() async {
    if (!mounted) return;
    // ! CHANGE THIS
    final localNameController = StreamController<Map<String, dynamic>>();

    _fetchService.fetchInstantNames(widget.currentFolderPath).listen(
      (data) {
        localNameController.add(data);
      },
      onDone: () => localNameController.close(),
      onError: (error) => localNameController.addError(error),
    );

    setState(() {
      currentWindowFileStream = localNameController.stream;
    });
  }

  String getParsedFileName(String fileName){
    if (fileName.endsWith('.enc')) {
      return fileName.substring(0, fileName.length - 4); // remove ".enc"
    }
    if (fileName.length > 12){
      return "${fileName.substring(0, 6)}...${fileName.substring(fileName.length - 5)}";
    }
    return fileName;
  }

  bool isFile(String name) => name.contains('.') && !name.startsWith('.');

  int getCrossAxisCount(double width) {
    if (width >= 1024) {
      // iPad width and bigger tablets
      return 5;
    } else if (width >= 600) {
      // Large phones, small tablets
      return 4;
    } else {
      // Phones in portrait (like iPhone)
      return 3;
    }
  }

  Widget _buildBody() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: currentWindowFileStream,
      builder: (context, snapshot) {
        if(!hasInternet){ return _buildNoWifi(); }
        else if (snapshot.connectionState == ConnectionState.waiting) { return _buildFillFolder(); } 
        else if (snapshot.hasError) { return _buildNoWifi(); } 
        else if (!snapshot.hasData || snapshot.data!.isEmpty) { return _buildEmpty(); }

        allFiles = snapshot.data!.keys.toList(); // Returns the names of files/directories
        // snapshot.data -> returns { [name]: { [details] } }

        return FilesSearchAndGrid(
          allFiles: allFiles,
          fileDataMap: snapshot.data!,
          currentFolderPath: widget.currentFolderPath,
          refreshFiles: refreshFiles,
        );
      });
  }
  
  Widget _buildNoWifi() {
    return 
      Column(
        children:[ SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: NoWifi(),
        ),]
      );
  }

  Widget _buildFillFolder(){
    return MyLoadAnimation(); // Show loading animation
  }

  Widget _buildEmpty(){
    return 
    // MyEmptyFolderAnim();
      LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Center(child: Text("No items found!")),
                  ],
                ),
              ),
            ),
          );
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.blue, Colors.red],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: 
          widget.currentFolderPath.contains("/")
          ? Text(widget.currentFolderPath.split("/").last) // get the last foldername: username/paht/Newfolder -> Newfolder
          : Text(
            AuthService.currentUsername!,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              size: 30,
            ),
            key: _buttonKey,
            onPressed: () {
              _showOptionsMenu();
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
        onRefresh: refreshFiles,
        child: _buildBody()
      ),
    );
  }
}
