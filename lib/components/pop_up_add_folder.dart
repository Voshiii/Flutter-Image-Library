import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';

class PopUpAddFolder extends StatefulWidget {

  const PopUpAddFolder({
    super.key,
  });

  @override
  State<PopUpAddFolder> createState() => _PopUpAddFolderState();
}

class _PopUpAddFolderState extends State<PopUpAddFolder> {
  final TextEditingController _textController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isCancelEnabled = false;

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
    setState(() {
      _isCancelEnabled = _textController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return 
      CupertinoAlertDialog(
      title: Text(
        "Folder name",
        style: TextStyle(fontSize: 22),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Please enter new folder name",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            
            CupertinoTextField(
              controller: _textController,
              placeholder: "Folder name",
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
          onPressed: _textController.text.trim().isEmpty
          ? null
          : () async {
            _authService.addFolder(_textController.text);
            Navigator.of(context).pop(true);
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
          onPressed: () => {
            Navigator.of(context).pop(false),
          },
        )
      ],

    );
  }
}