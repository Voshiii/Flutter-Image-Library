// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:photo_album/services/delete_service.dart';

class MyDeleteDialog extends StatefulWidget {
  final String folderName;

  const MyDeleteDialog({super.key, 
    required this.folderName,
  }); // Constructor

  @override
  _MyDeleteDialogState createState() => _MyDeleteDialogState();
}

class _MyDeleteDialogState extends State<MyDeleteDialog> {
  // final AuthService _authService = AuthService();
  final DeleteService _deleteService = DeleteService();
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
                    text: "Are you sure you want to delete folder ",
                    style: TextStyle(fontWeight: FontWeight.normal), // Normal style
                  ),
                  TextSpan(
                    text: widget.folderName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22,), // Bold style
                  ),
                  TextSpan(
                    text: "?",
                    style: TextStyle(fontWeight: FontWeight.normal), // Normal style
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
                  // _authService.deleteFolder(widget.folderName).then((data) {
                  _deleteService.deleteFolder(widget.folderName).then((data) {
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
