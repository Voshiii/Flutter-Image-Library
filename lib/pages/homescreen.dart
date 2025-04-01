import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/folder_button.dart';
import 'package:photo_album/components/logout_popup.dart';
import 'package:photo_album/components/my_delete_popup.dart';
import 'package:photo_album/components/no_internet.dart';
import 'package:photo_album/components/pop_up.dart';
import 'package:photo_album/pages/image_screen.dart';
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
  // final storage = FlutterSecureStorage();
  String? username = '';
  String? password = '';
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2000));
  }

  Future<void> refreshImages() async {
    setState(() {});
    hasInternet = await InternetConnection().hasInternetAccess;
  }


  Widget _buildImageView() {
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
          // return SingleChildScrollView(
          //   physics: const AlwaysScrollableScrollPhysics(),
          //   child: const Center(child: Text("No folders found")),
          // );
          return const Center(child: Text("No folders found")); // Handle empty data
        }

        // Display the data in a GridView
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of items per row
            crossAxisSpacing: 12, // Space between columns
            mainAxisSpacing: 12, // Space between rows
          ),
          padding: EdgeInsets.only(left: 12, right: 12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            return MyFolderButton(text: snapshot.data![index], onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute( // Switch Screens
                  builder: (context) => ImageScreen(folderName: snapshot.data![index]),
                ),
              )},
              onLongPress: () => {
                showDialog(
                context: context,
                builder: (BuildContext context) => MyDeleteDialog(
                  folderName: snapshot.data![index], 
                  text: "Are you sure you want to delete the folder ",
                  img: "",
                  ),
                ).then((reload) {
                  // Reload page after submitting
                  if(reload == true){
                    // Reload page after submitting
                    setState(() {});
                  }
                })
              }
            );
          },
        );
      },
    );
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
                builder: (BuildContext context) => PopUp(title: "Folder name", content: "Please enter new folder name"),
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
            icon: Icon(Icons.logout))
        ],
      ),
      body: RefreshIndicator( 
        onRefresh: refreshImages,
        child: _buildImageView()
      ),
    );
  }
}
