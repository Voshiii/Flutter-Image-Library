// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';

class MyDeleteDialog extends StatefulWidget {
  final String folderName;
  final String text;
  final String img;

  const MyDeleteDialog({
    required this.folderName,
    required this.text,
    required this.img,
  }); // Constructor

  @override
  _MyDeleteDialogState createState() => _MyDeleteDialogState();
}

class _MyDeleteDialogState extends State<MyDeleteDialog> {
  final AuthService _authService = AuthService();
  dynamic data;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: widget.text,
                    style: TextStyle(fontWeight: FontWeight.normal), // Normal style
                  ),
                  TextSpan(
                    text: widget.folderName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22,), // Bold style
                  ),
                ],
              ),),
        ]),
        
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 214, 214, 214),
                borderRadius: BorderRadius.circular(10),  
              ),
              // padding: EdgeInsets.only(left: 20, right: 20),
              child: TextButton(
                onPressed: ()  {
                  // Code to delete folder
                  _authService.deleteFolder(widget.folderName).then((data) {
                    if (data != null && data.isNotEmpty && !data["success"]) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting folder! Folder must be empty.')),
                      );
                      Navigator.of(context).pop();
                    } 
                    else {
                      if (mounted) {
                        Navigator.of(context).pop(true); // Close the dialog if successful
                      }
                    }
                  });

                },
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
              ),
            ),
            
            SizedBox(width: 20,),

            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 214, 214, 214),
                borderRadius: BorderRadius.circular(10),
              ),
              // padding: EdgeInsets.only(left: 20, right: 20),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                }, 
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black, fontSize: 15),
                )
              ),
            ),
          ],
        )
      ],
    );
  }
}
