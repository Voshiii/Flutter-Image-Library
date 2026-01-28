import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_album/components/home_page_comp/pdf_widget.dart';
import 'package:photo_album/services/noti_service.dart';
import 'dart:io';
import 'package:photo_album/services/upload_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class FileSelectorDialog extends StatefulWidget {
  final String folderPath; // folderpath including username/...
  final bool fromGallery;

  const FileSelectorDialog({
    super.key,
    required this.folderPath,
    required this.fromGallery,
  });

  @override
  FileSelectorDialogState createState() => FileSelectorDialogState();
}

class FileSelectorDialogState extends State<FileSelectorDialog> {
  bool _isUploading = false;
  
  List<File> _selectedFiles = [];
  List<String> filePaths = [];
  final Map<String, double> _uploadProgresses = {};

  UploadService uploadService = UploadService();
  final NotiService _notiService = NotiService();

  bool isVideoFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi');
  }
  bool isPDF(String path) {
    return path.toLowerCase().endsWith(".pdf");
  }


  final Map<String, Uint8List> _videoThumbnails = {};

  Future<Uint8List?> generateThumbnail(String videoPath) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.PNG,
      maxHeight: 150, // Size of the thumbnail
      quality: 75,
    );

    return uint8list;
  }

  @override
  void initState() {
    super.initState();
    print(widget.fromGallery);
    if(widget.fromGallery){
      print("Picking from gallery");
      _pickFromGallery();
    }
    else{
      print("Picking from files");
      _pickFromFiles();
    }
    
  }

  Future<void> _pickFromFiles() async {
    FilePickerResult? pickedFiles = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      // type: FileType.custom,
      // allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'mp4', 'txt'], // you can control what’s allowed
    );

    if (pickedFiles != null) {
      final newFiles = <File>[];
      final newPaths = <String>[];
      final newThumbnails = <String, Uint8List>{};

      for (var picked in pickedFiles.files) {
        // Some platforms only give `bytes` without a path (esp. web)
        if (picked.path != null) {
          final newFile = File(picked.path!);

          // Prevent duplicates
          if (!_selectedFiles.any((f) => f.path == newFile.path)) {
            newFiles.add(newFile);
            newPaths.add(picked.path!); // FilePicker gives `.name` directly

            if (isVideoFile(picked.path!)) {
              // Generate thumbnail for the video
              final thumb = await generateThumbnail(picked.path!);
              if (thumb != null) {
                newThumbnails[picked.name] = thumb;
              }
            }
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _selectedFiles.addAll(newFiles);
        filePaths.addAll(newPaths);
        _videoThumbnails.addAll(newThumbnails);
      });
    }

  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultipleMedia();

    if (pickedFiles.isNotEmpty) {
      final newFiles = <File>[];
      final newPaths = <String>[];
      final newThumbnails = <String, Uint8List>{};

      for (var file in pickedFiles) {
        final newFile = File(file.path);

        // Prevent duplicates
        if (!_selectedFiles.any((f) => f.path == newFile.path)) {
          newFiles.add(newFile);
          newPaths.add(file.name);

          if (isVideoFile(file.path)) {
            // Generate thumbnail for the video
            final thumb = await generateThumbnail(file.path);
            newThumbnails[file.name] = thumb!;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _selectedFiles.addAll(newFiles);
        filePaths.addAll(newPaths);
        _videoThumbnails.addAll(newThumbnails);
      });

    }
  }

  Widget getFileWidget(int index){
    if(isVideoFile(filePaths[index])){
      return Image.memory(
        _videoThumbnails[filePaths[index]]!,
        fit: BoxFit.cover,
      );
    }
    else if(isPDF(filePaths[index])){
      // Show a pdf thumbnail
      return PdfThumbnail(path: filePaths[index]);
    }
    return Image.file(
      _selectedFiles[index],
      fit: BoxFit.cover, // crop to fill the box nicely
    );
                          
      
  }

  // Shorten the name if too long
  String getShortenedName(String fileName){
    if (fileName.length > 12){
      return "${fileName.substring(0, 12)}...${fileName.substring(fileName.length - 3)}";
    }
    return fileName;
  }

  void _removeImages() {
    setState(() {
      _selectedFiles = [];
      _videoThumbnails.clear();
      filePaths = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isUploading,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: AlertDialog(
          backgroundColor: const Color.fromARGB(130, 5, 55, 69),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Select a file"),
              IconButton(
                onPressed: () => {
                  if(widget.fromGallery){
                    _pickFromGallery()
                  }
                  else{
                    _pickFromFiles()
                  }
                },
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Colors.blue,
                  size: 30,
                ),
              )
            ],
          ),
          content: 
          SizedBox(
            width: double.maxFinite,
            child: 
              _selectedFiles.isEmpty
                ? Container(
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  // mainAxisSize: MainAxisSize.min,
                  child: 
                  TextButton(onPressed: () => {
                    if(widget.fromGallery){
                      _pickFromGallery()
                    }
                    else{
                      _pickFromFiles()
                    }
                    
                  },
                  child: 
                  widget.fromGallery
                  ? Text(
                      "Open gallery",
                      style: TextStyle(color: Colors.black),
                    )
                  : Text(
                    "Open files",
                    style: TextStyle(color: Colors.black),
                  )
                  ),
                )
                : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _selectedFiles.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final fileName = filePaths[index].split('/').last;
        
                    return Column(
                      children: [
                        ListTile(
                          leading: SizedBox(
                            width: 80,
                            height: 80,
                            child: 
                            Center(child: getFileWidget(index)),
                            
                          ),
                        
                          title: Text(
                            getShortenedName(fileName),
                            style: TextStyle(
                              fontSize: 12
                            ),
                          ),
                          
                          trailing: 
                          _isUploading
                            ? SizedBox()
                            : IconButton(
                            onPressed: () => {
                              setState(() {
                                _selectedFiles.removeAt(index);
                                filePaths.removeAt(index);
                              })
                            },
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                          )  
                          
                        ),
        
                        if(_isUploading)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SizedBox(
                              height: 5,
                              child: LinearProgressIndicator(value: _uploadProgresses[filePaths[index]], color: Colors.blue,),
                            ),
                          )
                      
                      ],
                    );
                  },
                )
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: !_isUploading ? _removeImages : uploadService.cancelUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedFiles.isNotEmpty
                    ? const Color.fromARGB(190, 244, 67, 54)
                    : const Color.fromARGB(255, 138, 138, 138),
                  ),
                  child: !_isUploading
                    ? Text("Clear", style: TextStyle(color: Colors.black),)
                    : Text("Cancel", style: TextStyle(color: Colors.black),)
                ),
        
                SizedBox(width: 10,),
        
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedFiles.isNotEmpty && !_isUploading
                    ? const Color.fromARGB(195, 18, 158, 0)
                    : const Color.fromARGB(255, 138, 138, 138),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  onPressed: () async {
                    if (_selectedFiles.isNotEmpty && !_isUploading) {
                      setState(() {
                        _isUploading = true;
                      });
        
                      final uploadFutures = List.generate(_selectedFiles.length, (i) {
                        final file = _selectedFiles[i];
                        final filePath = filePaths[i];
                        setState(() {
                          _uploadProgresses[filePath] = 0.0;
                        });
        
                        return uploadService.uploadFile(
                          file: file,
                          folderPath: widget.folderPath,
                          imageName: filePath,
                          onProgress: (progress) {
                            setState(() {
                              _uploadProgresses[filePath] = progress;
                            });
                          },
                        );
                      });
        
        
                      try {
                        final result = await Future.wait(uploadFutures);
                        bool success;
                        if(result.contains(false)){
                          success = false;
                        }
                        else{
                          success = true;
                        }
        
                        setState(() {
                          _isUploading = false;
                        });
                        if(!context.mounted) return;
                        success
                        ? ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Image uploaded successfully!')),
                        )
                        : ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to upload!')),
                        );
        
                        setState(() {
                          _isUploading = false;
                        });
        
                        _notiService.fileUploaded(success);
        
                        Navigator.of(context).pop(success);
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
                        SnackBar(content: Text('No file selected!')),
                      );
                    }
                
                  },
                  child: Text("Upload", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
