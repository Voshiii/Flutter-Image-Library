import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:photo_album/services/upload_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ImageSelectorDialog extends StatefulWidget {
  final String folderName;

  const ImageSelectorDialog({super.key, required this.folderName});

  @override
  _ImageSelectorDialogState createState() => _ImageSelectorDialogState();
}

class _ImageSelectorDialogState extends State<ImageSelectorDialog> {
  File? _selectedFile;
  String filePath = "";

  double _uploadProgress = 0.0;
  bool _isUploading = false;
  
  UploadService uploadService = UploadService();

  bool isVideoFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi');
  }

  Uint8List? _videoThumbnail;

  Future<void> generateThumbnail(String videoPath) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.PNG,
      maxHeight: 150, // Size of the thumbnail
      quality: 75,
    );

    setState(() {
      _videoThumbnail = uint8list;
    });
  }

  Future<void> _pickImage() async {
    // NOT FULLY DONE YET:
    // Make some optimization to send and retrieve video's -> loading bars
    // When the user cancels, remove it from the server -> server side. Options:
    
    // Use a temporary location to store incoming uploads.
    // Track upload state (e.g., store progress or session info).
    // Set a timeout or cleanup job:
    // If the upload doesn’t complete within a certain time, delete the partial file.
    // Expose a cancel endpoint (optional):
    // When the client cancels, it can also notify the server to delete the partial file (e.g., via a DELETE request with a unique ID).

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickMedia();

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final path = pickedFile.path;

      if (isVideoFile(path)) {
        final uint8list = await VideoThumbnail.thumbnailData(
          video: path,
          imageFormat: ImageFormat.PNG,
          maxHeight: 150,
          quality: 75,
        );

        if (!mounted) return;
        setState(() {
          print("Setting state for vids");
          _videoThumbnail = uint8list;
          _selectedFile = file;
          filePath = file.uri.pathSegments.last;
        });
      } else {
        if (!mounted) return;
        setState(() {
          print("Setting state for images");
          _videoThumbnail = null;
          _selectedFile = file;
          filePath = file.uri.pathSegments.last;
        });
      }
    }

  }

  void _removeImage() {
    setState(() {
      _selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isUploading,
      child: AlertDialog(
        title: Text("Select an Image"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Column(
                children: [
                  if (_selectedFile != null)
                    isVideoFile(_selectedFile!.path)
                      ? (_videoThumbnail != null
                        ? Image.memory(_videoThumbnail!, height: 150)
                        : const CircularProgressIndicator())
                      : Image.file(_selectedFile!, height: 150)
                  else Container(
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
      
            if (_isUploading) 
              SizedBox(
                height: 5,
                child: LinearProgressIndicator(value: _uploadProgress, color: Colors.blue,),
              ),
      
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: !_isUploading ? _removeImage : uploadService.cancelUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedFile != null 
                  ? Colors.red
                  : const Color.fromARGB(255, 138, 138, 138),
                ),
                child: !_isUploading
                  ? Text("Clear", style: TextStyle(color: Colors.black),)
                  : Text("Cancel", style: TextStyle(color: Colors.black),)
              ),
      
              SizedBox(width: 10,),
      
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedFile != null && !_isUploading
                  ? const Color.fromARGB(255, 18, 158, 0)
                  : const Color.fromARGB(255, 138, 138, 138),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                onPressed: () async {
                  if (_selectedFile != null && !_isUploading) {
                    try {
      
                      final bool success = await uploadService.uploadFile(
                        file: _selectedFile!,
                        folderName: widget.folderName,
                        imageName: filePath,
                        onProgress: (progress) {
                          setState(() {
                            _uploadProgress = progress;
                            _isUploading = true;
                          });
                        },
                      );
      
                      setState(() {
                        _isUploading = false;
                      });
      
                      success
                      ? ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Image uploaded successfully!')),
                      )
                      : ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to upload!')),
                      );
      
                      Navigator.of(context).pop(true);
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
      ),
    );
  }


}
