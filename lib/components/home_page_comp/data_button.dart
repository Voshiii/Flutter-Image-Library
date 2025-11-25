import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_album/cache/file_data_cache.dart';
import 'package:photo_album/themes/theme_provider.dart';
import 'package:provider/provider.dart';

// The button which shows the item
class DataButton extends StatefulWidget {
  final String parsedFileName;
  final VoidCallback onTap;
  final dynamic data;
  final bool isFile;
  final String folderPath;
  final String fullFileName;
  // final dynamic cachedData;

  // ! Change to "IconButton"
  const DataButton({
    super.key,
    required this.parsedFileName, //  Shorter file name e.g. "name...e.png"
    required this.onTap,
    required this.data, // the information e.g. size or date added
    required this.isFile,
    required this.folderPath,
    required this.fullFileName,
    // required this.cachedData
    });

  @override
  State<DataButton> createState() => _DataButtonState();
}

class _DataButtonState extends State<DataButton> {
  late ThemeData currentTheme; // Get the dark mode or light mode to change button colors

  String formattedDate = ""; // Used for formatted date in dd/mm/yyyy
  // bool expanded = false;
  String decodedText = "";
  Uint8List decodedBytes = Uint8List(0);

  dynamic fileData = {};

  @override
  void initState() {
    super.initState();
    _loadTheme();
    formatDate();

    getData();
  }

  void getData() async {
    if(widget.isFile){
      final newData = await FileCacheHelper.getFileData(widget.fullFileName, widget.folderPath);
      setState(() {
        fileData = newData;
      });
    }
    // else it's just a folder
  }

  void formatDate(){
    String isoDate = widget.data["modifiedAt"];
    DateTime date = DateTime.parse(isoDate);
    formattedDate = DateFormat('dd/MM/yyyy').format(date);
    setState(() {
      formattedDate = DateFormat('dd/MM/yyyy').format(date);
    });
  }

  void _loadTheme() async {
    // Get dark or light mode
    currentTheme = Provider.of<ThemeProvider>(context, listen: false).getThemeData();
  }

  // Handle data if the file is a text
  void handleDataText(data){
    final base64Str = data ?? '';
    final decodedBytes = base64Str.isEmpty ? Uint8List(0) : base64Str;
    setState(() {
      decodedText = utf8.decode(decodedBytes);
    }); 
  }

  // Handle data if the file is an image
  void handleDataImg(data){
    final base64Str = data ?? '';
    setState(() {
      decodedBytes = base64Str.isEmpty ? Uint8List(0) : base64Str;
    });
  }

  // Get the file size and round
  String _roundValue(int bytes) {
    double mb = bytes / 1e6;
    String amount;

    if (mb >= 1e6) {
      amount = '${(mb / 1e6).toStringAsFixed(2)} TB';
    } else if (mb >= 1e3) {
      amount = '${(mb / 1e3).toStringAsFixed(2)} GB';
    } else if (mb >= 1.0) {
      amount = '${mb.toStringAsFixed(2)} MB';
    } else if (mb >= 1 / 1024) {
      amount = '${(mb * 1024).toStringAsFixed(2)} KB';
    } else {
      amount = '${(mb * 1024 * 1024).toStringAsFixed(2)} B';
    }

    return amount;
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent;

    // ! Handle empty data -> currently shows an icon
    if (fileData.isEmpty){
      previewContent = Icon(Icons.file_present);
    }
    else if (widget.parsedFileName.endsWith('.txt')) { 
      // Handle text data
      handleDataText(fileData);
      previewContent = Container(
        width: 40, // make it small
        height: 60, // proportion like a paper
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(1),
          border: Border.all(color: Colors.grey.shade400, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: FittedBox( // scales down text if needed
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 90,
            ),
            child: Text(
              decodedText,
              // maxLines: expanded ? null : 10,
              maxLines: 10,
              // overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    } else if (widget.parsedFileName.endsWith('.png') || widget.parsedFileName.endsWith('.jpg')) {
      // Handle image data
      handleDataImg(fileData);
      previewContent = Image.memory(
        decodedBytes,
        // height: expanded ? 10 : 50,
        height: 50,
        fit: BoxFit.cover,
      );
    // Add more
    } else if(widget.parsedFileName.endsWith(".mov") || widget.parsedFileName.endsWith(".mpv")){
      // Handle video data -> thumbnail
      // Add a video play button
      handleDataImg(fileData);
      previewContent = Stack(
        alignment: Alignment.center,
        children: [
          Image.memory(
            decodedBytes,
            // height: expanded ? 10 : 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          Icon(
            Icons.play_circle_outline,
            color: const Color.fromARGB(255, 202, 202, 202),
          ),
        ],
      );
    } else if (widget.parsedFileName.endsWith('.pdf')) {
      // Handle pdf data
      previewContent = Text(
        "PDF preview not implemented here. Tap to open.",
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    } else {
      // Handle unknown data
      previewContent = Icon(Icons.file_present);
    }


    return GestureDetector(
      onTap: widget.onTap,
      child: Material(

        child: InkWell(
          onTap: widget.onTap,
          // TODO CHANGE THIS
          // splashColor: currentTheme == darkMode 
          //   ? const Color.fromARGB(255, 58, 90, 99) 
          //   : const Color.fromARGB(255, 138, 186, 198),
          // highlightColor: currentTheme == darkMode
          //   ? const Color.fromARGB(255, 71, 97, 104) 
          //   : const Color.fromARGB(255, 167, 215, 227),
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              // * If file is not a Directory
              child: widget.isFile
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  previewContent,
                  Text(widget.parsedFileName),
                  Text(
                    _roundValue(widget.data["sizeBytes"]),
                    style: TextStyle(
                      color: const Color.fromARGB(216, 116, 116, 116),
                      fontSize: 11
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: const Color.fromARGB(216, 116, 116, 116),
                      fontSize: 11
                    ),
                  ),
                ],
              )
              // * If file is a Directory
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder,
                    size: 65,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(widget.parsedFileName),
                  Text(
                    'Items: ${widget.data["itemCount"].toString()}',
                    style: TextStyle(
                      color: const Color.fromARGB(216, 116, 116, 116),
                      fontSize: 12
                    ),
                  ),
                ],  
              ),
            ),
          ),
        ),
      ),
      
    );
  }
}