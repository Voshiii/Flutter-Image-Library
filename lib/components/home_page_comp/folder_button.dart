import 'package:flutter/material.dart';
import 'package:photo_album/themes/dark_mode.dart';
import 'package:photo_album/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class MyFolderButton extends StatefulWidget {
  final String folderName;
  final VoidCallback onTap;
  final Color backgroundColor;
  final dynamic data;

  const MyFolderButton({
    super.key,
    required this.folderName,
    required this.onTap,
    required this.backgroundColor,
    required this.data,
    });

  @override
  State<MyFolderButton> createState() => _MyFolderButtonState();
}

class _MyFolderButtonState extends State<MyFolderButton> {
  late ThemeData currentTheme;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  void _loadTheme() async {
    currentTheme = Provider.of<ThemeProvider>(context, listen: false).getThemeData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Material(

        child: InkWell(
          onTap: widget.onTap,
          splashColor: currentTheme == darkMode 
            ? const Color.fromARGB(255, 58, 90, 99) 
            : const Color.fromARGB(255, 138, 186, 198),
          highlightColor: currentTheme == darkMode
            ? const Color.fromARGB(255, 71, 97, 104) 
            : const Color.fromARGB(255, 167, 215, 227),
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder,
                    size: 65,
                    color: Colors.blue,
                  ),
                  Text(widget.folderName),
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