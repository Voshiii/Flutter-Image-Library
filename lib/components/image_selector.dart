import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:photo_album/auth/auth.dart';

class ImageSelectorDialog extends StatefulWidget {
  final String folderName; // Change this to accept a parameter

  ImageSelectorDialog({required this.folderName}); // Constructor

  @override
  _ImageSelectorDialogState createState() => _ImageSelectorDialogState();
}

class _ImageSelectorDialogState extends State<ImageSelectorDialog> {
  File? _selectedImage;
  String imagePath = "";
  
  final AuthService _authService = AuthService();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        //
        imagePath = File(pickedFile.path).uri.pathSegments.last;  // Get the name of the image file
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select an Image"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _selectedImage != null
              ? Image.file(_selectedImage!, height: 150) // Show selected image
              : Container(
                  height: 150,
                  width: 150,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 50, color: Colors.grey),
                ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Select Image", style: TextStyle(color: Colors.black),),
              ),
              SizedBox(width: 10,),
              ElevatedButton(
                onPressed: _removeImage,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text("Reset", style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 213, 213, 213), // Set the background color
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Optional: Add padding
          ),
          onPressed: () async {
            if (_selectedImage != null) {
              try {
                await _authService.addImage(_selectedImage, widget.folderName, imagePath);

                // Optionally, show a success message here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Image uploaded successfully!')),
                );
                Navigator.of(context).pop(true);
                // Navigator.pop(context);
              }
              catch(e){
                // Handle any errors that may occur during upload
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Upload failed: $e')),
                );
              }
            }
            else{
              // Handle case where no image is selected
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No image selected!')),
              );
            }
            

            // Implement upload function
            // _authService.addImage(_selectedImage, "NewName", widget.folderName);
            // Navigator.pop(context); // Close dialog
          },
          child: Text("Upload", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}

// Function to show the dialog
// void showImageSelectorDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return ImageSelectorDialog(folderName: ,);
//     },
//   );
// }
