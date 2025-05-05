import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_album/auth/auth.dart';

class MyImagePopUp extends StatefulWidget {
  final String folderName;
  // final String img;
  final Uint8List img;
  final String imgName;

  const MyImagePopUp({
    required this.folderName,
    required this.img,
    required this.imgName,
  }); // Constructor

  @override
  _MyDeleteDialogState createState() => _MyDeleteDialogState();
}

class _MyDeleteDialogState extends State<MyImagePopUp> {
  final AuthService _authService = AuthService();
  dynamic data;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Column(
          children: [
            Image.memory(widget.img),
        ]),
        
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),  
              ),
              child: TextButton(
                onPressed: ()  {
                  // Code to delete image
                  _authService.deleteImage(widget.folderName, widget.imgName).then((_) {
                    Navigator.of(context).pop(true);
                  });
                },
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
              ),
            ),

            SizedBox(width: 20,),

            Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),  
              ),
              child: TextButton(
                onPressed: () async {
                  Uint8List bytes = widget.img;

                  // Save to gallery
                  final result = await ImageGallerySaver.saveImage(bytes);
                  if(result['isSuccess'] == true){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Succesfully saved image.')),
                    );
                    Navigator.of(context).pop();
                  }
                  else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving image!')),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.black, fontSize: 15),
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
