import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/settings_page_comp/filled_bar.dart';
import 'package:photo_album/pages/change_pass_screen.dart';
import 'package:photo_album/pages/change_username_screen.dart';
import 'package:photo_album/services/fetch_service.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({super.key});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  String? username;
  String? email;
  // double assignedStorage = 10; // Place holder
  // double usedStorage = 0.5; // Place holder
  int assignedStorage = 0; // Place holder
  double usedStorage = 0.0; // Place holder
  bool faceIdPref = false; // Check if faceID is active to log in


  @override
  void initState() {
    super.initState();
    getCredentials();
  }

  double bytesToGB(String? bytesStr) {
    final bytes = double.tryParse(bytesStr ?? '0') ?? 0;
    final gb = bytes / (1024 * 1024 * 1024);
    return (gb * 100).roundToDouble() / 100; // rounded to 2 decimals
  }

  void getCredentials() async {
    username = AuthService.currentUsername;
    final mail = await AuthService.getEmail();
    final pref = await AuthService.getFaceIdPref();
    final storage = await FetchService.getStorageDetails();
    final maxStorage = storage["maxStorage"];
    final currStorage = bytesToGB(storage["storageUsed"]);

    setState(() {
      faceIdPref = pref;
      email = mail;
      assignedStorage = int.parse(maxStorage ?? "0");
      usedStorage = currStorage;
    });
  }

  void setFaceIdPref(bool val) async {
    await AuthService.saveFaceIDPref(val);
  }

  Widget _userAccountBody(){
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDivider(),
                ListTile(
                  title: const Text("Username"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, //  so row only takes needed space
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: AuthService.currentUsernameTest,
                        builder: (context, username, _) {
                          return Text(
                            // If for some reason the user is not logged in, default "NOT LOGGED IN"
                            (username != null && username != "NOT LOGGED IN") 
                                ? username 
                                : "NOT LOGGED IN",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChangeUsernameScreen(username: username!, email: email!,)),
                    );
                  },
                ),
                _buildDivider(),
        
                ListTile(
                  title: Text("Email"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        // If for some reason the user it not logged in, default "NOT LOGGED IN"
                        email != null
                            ? "$email"
                            : "NOT LOGGED IN",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDivider(),
        
                ListTile(
                  title: Text("Password"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Placeholder
                      Text(
                        "••••••••••",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChangePasswordScreen(email: email!, username: username!,)),
                    );
                  },
                ),
                _buildDivider(),
              ]
            )
          )
        ),
    
        SizedBox(height: 25,),
        Text(
          "Usage & Privacy",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
        SizedBox(height: 5,),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDivider(),
                ListTile(
                  // Bar for storage used
                  title: Text("Storage Used"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 120, // give it some fixed space
                        child: ColoredBar(value: usedStorage, maxValue: assignedStorage),
                      ),
                      
                      const SizedBox(width: 8),
                      Text("${assignedStorage.toString()} GB"),
                      
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () {
                    print("TODO: Change storage amount");
                  },
                ),
                _buildDivider(),

                ListTile(
                  title: Text(
                    "Face ID",
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Platform.isIOS
                      ? CupertinoSwitch(
                          value: faceIdPref,
                          onChanged: (value) {
                            setFaceIdPref(value);
                            setState(() => faceIdPref = value);
                          },
                        )
                      : Switch(
                          value: faceIdPref,
                          onChanged: (value) {
                            setFaceIdPref(value);
                            setState(() => faceIdPref = value);
                          },
                        )
                    ],
                  ),
                ),
                _buildDivider(),
              ]
            )
          )
        ),

        SizedBox(height: 25,),
        Text(
          "Deletion",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),
        ),
        SizedBox(height: 5,),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDivider(),
                ListTile(
                  title: Text(
                    "Delete Account",
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    print("TODO: Delete account");
                  },
                ),
                _buildDivider(),
              ]
            )
          )
        ),
      ],
    );
  }

  Widget _buildDivider() => Divider(height: 1, thickness: 1.5, color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _userAccountBody(),
    );
  }
}