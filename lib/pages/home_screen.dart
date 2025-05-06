import 'package:flutter/cupertino.dart';
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

// This class (or a class that this class inherits from) is marked as 
//'@immutable', but one or more of its instance fields aren't final: 
//HomeScreen.folderStream
// ignore: must_be_immutable
class HomeScreen extends StatefulWidget {
  late Stream<List<dynamic>> folderStream;

  HomeScreen({
    super.key,
    required this.folderStream
  });

  @override
  State<HomeScreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool hasInternet = true;

  TextEditingController _searchController = TextEditingController();
  List<dynamic> _allFolders = [];
  List<dynamic> _filteredFolders = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2000));
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (!mounted) return;
    setState(() {
      _filteredFolders = _allFolders
          .where((folder) => folder["name"].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
   _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> refreshFolders() async {
    if (!mounted) return;
    setState(() {
      widget.folderStream = _authService.fetchInstantFolder();
      _allFolders = [];
      _filteredFolders = [];
    });
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
      stream: widget.folderStream,
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

        if (_allFolders.isEmpty || _allFolders.length != snapshot.data!.length) {
          _allFolders = snapshot.data!;
          _filteredFolders = _searchController.text.isEmpty
              ? _allFolders
              : _allFolders
                  .where((folder) => folder["name"]
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                  .toList();
        }


        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  onChanged: (_) => _onSearchChanged(),
                  placeholder: 'Search folders...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.clear),
                ),
              ),
          
              Expanded(
                child: Stack(
                  children: [
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _filteredFolders.length,
                      itemBuilder: (context, index) {
                        final parsedFolderName = getParsedFolderName(_filteredFolders[index]["name"]);
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
                
                                showContextMenu(context, layerLink, position, size, overlayEntry, refreshFolders, _filteredFolders[index], parsedFolderName);
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
                                  data: _filteredFolders[index]
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30,)
            ],
          ),
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
                if(reload == true){refreshFolders();}
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
