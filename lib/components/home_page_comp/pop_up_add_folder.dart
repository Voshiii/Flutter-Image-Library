import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/services/upload_service.dart';

class PopUpAddFolder extends StatefulWidget {
  final String currentFolderPath;


  const PopUpAddFolder({
    super.key,
    required this.currentFolderPath,
  });

  @override
  State<PopUpAddFolder> createState() => _PopUpAddFolderState();
}

class _PopUpAddFolderState extends State<PopUpAddFolder> {
  final TextEditingController _textController = TextEditingController();
  final UploadService _uploadService = UploadService();
  bool _isTextValid = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextChanged);
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    final text = _textController.text.trim();

    // regex checks if text contains any of: \ / . , ' " ; : < > ( ) { } [ ] |
    final forbiddenPattern = RegExp(r'''[\\/.,'" ;:<>(){}\[\]\|]''');
    setState(() {
      if (forbiddenPattern.hasMatch(text)) {
        _isTextValid = false;
      }
      else{
        _isTextValid = _textController.text.trim().isNotEmpty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(
        "Folder name",
        style: TextStyle(fontSize: 22),
      ),

      content: Column(
        // mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "Please enter new folder name",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          
          // Material(
          //   child: CupertinoTextField(
          //     controller: _textController,
          //     placeholder: "Folder name",
          //     style: TextStyle(
          //     color: CupertinoTheme.of(context).brightness == Brightness.dark
          //         ? CupertinoColors.white
          //         : CupertinoColors.black,
          //     ),
          //   ),
          // ),

          SizedBox(
            child: Material(
              child: TextField(
                controller: _textController,
                autocorrect: false,
                style: TextStyle(
                  color: CupertinoTheme.of(context).brightness == Brightness.dark
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ),

                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Folder name',
                  floatingLabelStyle: TextStyle(
                    fontSize: 12, // size when it floats
                  ),
                ),
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: !_isTextValid
          ? null
          : () async {
            _uploadService.addFolder(_textController.text, widget.currentFolderPath);
            Navigator.of(context).pop(true);
          },
          child: Text(
            "Ok",
            style: _isTextValid
            ? TextStyle(color: Theme.of(context).colorScheme.primary)
            : TextStyle(color: const Color.fromARGB(255, 138, 138, 138))
          ),
        ),

        CupertinoDialogAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: const Color.fromARGB(255, 227, 1, 1)),
          ),
          onPressed: () => {
            Navigator.of(context).pop(false),
          },
        )
      ],

    );
  }
}