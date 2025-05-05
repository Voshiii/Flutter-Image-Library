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
          GestureDetector(
            onTap: _pickImage,
            child: Column(
              children: [
                _selectedImage != null
                    ? Image.file(_selectedImage!, height: 150) // Show selected image
                    : Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey[300],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Select image", style: TextStyle(color: const Color.fromARGB(255, 44, 44, 44)),),
                            Icon(Icons.image, size: 50, color: Colors.grey),
                          ],
                        ),
                      ),
              ],
            ),
          ),
          
          SizedBox(height: 10),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _removeImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedImage != null 
                ? Colors.red
                : const Color.fromARGB(255, 138, 138, 138),
              ),
              child: Text("Clear", style: TextStyle(color: Colors.black),),
            ),

            SizedBox(width: 10,),

            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: _selectedImage != null
                ? const Color.fromARGB(255, 18, 158, 0)
                : const Color.fromARGB(255, 138, 138, 138),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              onPressed: () async {
                if (_selectedImage != null) {
                  try {
                    await _authService.addImage(_selectedImage, widget.folderName, imagePath);
            
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
            
              },
              child: Text("Upload", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ],
    );
  }
}
