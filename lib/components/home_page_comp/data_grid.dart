import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/components/home_page_comp/data_button.dart';
import 'package:photo_album/components/home_page_comp/file_on_hold_popup.dart';
import 'package:photo_album/pages/home_screen.dart';
import 'package:photo_album/pages/image_viewer_screen.dart';
import 'package:photo_album/services/fetch_service.dart';

class FilesSearchAndGrid extends StatefulWidget {
  final List<dynamic> allFiles;
  final Map<String, dynamic> fileDataMap; // stores the { [name]: { [fileInfo] } }
  final String currentFolderPath;
  final Future<void> Function()? refreshFiles;

  const FilesSearchAndGrid({
    Key? key,
    required this.allFiles,
    required this.fileDataMap,
    required this.currentFolderPath,
    required this.refreshFiles,
  }) : super(key: key);

  @override
  FilesSearchAndGridState createState() => FilesSearchAndGridState();
}

class FilesSearchAndGridState extends State<FilesSearchAndGrid> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late List<dynamic> _filteredFiles;

  @override
  bool get wantKeepAlive => true;

  int test = 0;

  // Map<String, dynamic> cachedData = {};

  @override
  void initState() {
    super.initState();
    _filteredFiles = widget.allFiles;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant FilesSearchAndGrid oldWidget) {
    print("DID UPDATE WIDGET!");
    super.didUpdateWidget(oldWidget);

    // If the file list changed, refresh filtered list
    if (oldWidget.allFiles != widget.allFiles) {
      setState(() {
        _filteredFiles = _searchController.text.isEmpty
            ? widget.allFiles
            : widget.allFiles
                .where((file) => file
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase()))
                .toList();
      });
    }
  }

  // Shorten the name if it's too long (e.g. veryLong...me.jpg)
  String getParsedFileName(String fileName){
    String newFileName = fileName;
    if (fileName.endsWith('.enc')) { // Files are encrypted and it still has the extention
      newFileName = fileName.substring(0, fileName.length - 4); // remove ".enc"
    }

    // The client only gets a thumbnail from the server if it's a video
    // The returned filename with me "thumb_fileName.mov.jpg.enc"
    // Remove the ".enc", ".jpg" and the "thumb_"
    if(newFileName.startsWith("thumb_")){
      newFileName = newFileName.substring(6, newFileName.length - 4);
    }
    if (newFileName.length > 12){
      return "${newFileName.substring(0, 6)}...${newFileName.substring(newFileName.length - 5)}";
    }
    return newFileName;
  }

  void _onSearchChanged() {
    print("ON SEARCH ACTIVATED");
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFiles = widget.allFiles
        .where((file) => file.toLowerCase().contains(query))
        .toList();
    });
  }

  bool isFile(String name) => name.contains('.') && !name.startsWith('.');

  int getCrossAxisCount(double width) {
    if (width >= 1024) {
      // iPad width and bigger tablets
      return 5;
    } else if (width >= 600) {
      // Large phones, small tablets
      return 4;
    } else {
      // Phones in portrait (like iPhone)
      return 3;
    }
  }

  // When going to new folder, request the data
  Stream<Map<String, dynamic>> getFolderNewData(String folderName){
    final FetchService fetchService = FetchService();
    final localNameController = StreamController<Map<String, dynamic>>();

    fetchService.fetchInstantNames(folderName).listen(
      (data) {
        localNameController.add(data);
      },
      onDone: () => localNameController.close(),
      onError: (error) => localNameController.addError(error),
    );

    return localNameController.stream;
  }

  @override
  Widget build(BuildContext context) {
    print("THE MAIN WINDOW UPDATED!");
    print(test);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Only unfocus if something is focused
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      },
      child: Column(
        children: [
          searchBarWidget(),
          Expanded(child: buildGridView()),
        ],
      ),
    );
  }

  Widget searchBarWidget(){
    print("Resetting search?");
    return Padding(
      padding: const EdgeInsets.all(12),
      child: CupertinoSearchTextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        placeholder: 'Search files...',
        prefixIcon: Icon(Icons.search),
        suffixIcon: Icon(Icons.clear),
        style: TextStyle(
          color: CupertinoTheme.of(context).brightness == Brightness.dark
              ? CupertinoColors.white
              : CupertinoColors.black,
        ),
      ),
    );
  }

  Widget buildGridView(){
    final crossAxisCount = getCrossAxisCount(MediaQuery.of(context).size.width);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      itemCount: _filteredFiles.length,
      itemBuilder: (context, index) {
        // TODO Find out why the widgets keep resetting
        print("RESETTING THIS SPECIFIC WIDGET");

        final fileName = _filteredFiles[index];
        final parsedFileName = getParsedFileName(fileName);
        final isActualFile = isFile(fileName);


        // The button which shows the item
        // -> Each item, folder, image, file, etc.
        // Widget myBuildDataButton = buildDataButton(fileName, parsedFileName, isActualFile, cachedData);
        Widget myBuildDataButton = buildDataButton(fileName, parsedFileName, isActualFile, index);

        final layerLink = LayerLink();
        final key = GlobalKey();
        OverlayEntry? overlayEntry;

        return GestureDetector(
          key: key,
          onLongPress: () {
            final renderBox = key.currentContext!.findRenderObject() as RenderBox;
            final position = renderBox.localToGlobal(Offset.zero);
            final size = renderBox.size;

            showContextMenu(
              context,
              layerLink,
              position,
              size,
              overlayEntry,
              widget.refreshFiles,
              widget.fileDataMap[fileName], // data
              parsedFileName,
              widget.currentFolderPath,
              fileName,
              isActualFile,
              myBuildDataButton
            );
          },
          child: CompositedTransformTarget(
            link: layerLink,
            child: 
            myBuildDataButton
          ),
        );
      }

    );
  }

  // This is the actual button seen
  // Widget buildDataButton(fileName, parsedFileName, isActualFile, cachedData) {
  Widget buildDataButton(fileName, parsedFileName, isActualFile, index) {
    return DataButton(
      key: ValueKey(fileName), // keeps state between searches
      fullFileName: fileName, // full name of the file
      parsedFileName: parsedFileName, // short version e.g "longName...g.png"
      onTap: () {

        if (isActualFile){
          // TODO If it is a file, open it
          print("IsFile");
          Navigator.push(
            context,
            MaterialPageRoute(
              // builder: (context) => MyTestInterface(),
              builder: (context) => ImageViewerScreen(files: _filteredFiles, folderPath: widget.currentFolderPath, initialIndex: index,)
            ),
          );
        }
        else {
          // Make the new folderPath: username -> username/folderName
          final newCurrentFolderPathName = "${widget.currentFolderPath}/$fileName";
          final fileStream = getFolderNewData(newCurrentFolderPathName);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                // key: ValueKey(widget.currentFolderPath),
                fileStream: fileStream,
                currentFolderPath: newCurrentFolderPathName
              ),
            ),
          );
        }
      },
      data: widget.fileDataMap[fileName],
      isFile: isActualFile,
      folderPath: widget.currentFolderPath,
      // cachedData: cachedData,
    );
  }

  // @override
  // void dispose() {
  //   _searchController.dispose();
  //   _searchFocusNode.dispose();
  //   super.dispose();
  // }

}