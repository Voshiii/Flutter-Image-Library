import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';

class PopUpRenameFolder extends StatefulWidget {
  final String oldFolderName;

  const PopUpRenameFolder({
    super.key,
    required this.oldFolderName,
  });

  @override
  State<PopUpRenameFolder> createState() => _PopUpRenameFolderState();
}

class _PopUpRenameFolderState extends State<PopUpRenameFolder> {
  final TextEditingController _textController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isCancelEnabled = false;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.oldFolderName;
    final text = _textController.text.trim();
    _isCancelEnabled = !(text.isEmpty || text == widget.oldFolderName);
    _textController.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {
      final text = _textController.text.trim();
      _isCancelEnabled = !(text.isEmpty || text == widget.oldFolderName);
    });
  }

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
              style: TextStyle(
              color: CupertinoTheme.of(context).brightness == Brightness.dark
                  ? CupertinoColors.white
                  : CupertinoColors.black,
              ),
            )
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: !_isCancelEnabled
          ? null
          : () async {
            final bool result = await _authService.renameFolder(widget.oldFolderName, _textController.text);
            if (result == false) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to rename folder!')),
              );
            }
            Navigator.of(context).pop(result);
          },
          child: Text(
            "Ok",
            style: _isCancelEnabled
            ? TextStyle(color: Colors.blue)
            : TextStyle(color: const Color.fromARGB(255, 138, 138, 138))
          ),
        ),
        CupertinoDialogAction(
          child: Text(
            "Cancel",
            style: TextStyle(color: const Color.fromARGB(255, 227, 1, 1)),
          ),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        )
      ],

    );
  }
}