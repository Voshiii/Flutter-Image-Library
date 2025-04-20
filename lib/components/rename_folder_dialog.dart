import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';

class PopUpRenameFolder extends StatefulWidget {
  final String oldFolderName;

  PopUpRenameFolder({
    super.key,
    required this.oldFolderName,
  });

  @override
  State<PopUpRenameFolder> createState() => _PopUpRenameFolderState();
}

class _PopUpRenameFolderState extends State<PopUpRenameFolder> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.oldFolderName;
  }

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return 
      CupertinoAlertDialog(
      title: Text(
        "Rename folder",
        style: TextStyle(fontSize: 22),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Please enter new folder name for ${widget.oldFolderName}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            CupertinoTextField(
              controller: _textController,
              placeholder: "New folder name",
            )
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: () => {
            _authService.renameFolder(widget.oldFolderName, _textController.text),
            Navigator.of(context).pop(true),
          },
        ),
        CupertinoDialogAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: const Color.fromARGB(255, 46, 46, 46)),
          ),
          onPressed: () => {
            Navigator.of(context).pop(false),
          },
        )
      ],

    );
  }
}