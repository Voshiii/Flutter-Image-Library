import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
// import 'package:photo_album/components/text_field.dart';

class PopUp extends StatelessWidget {
  final String title;
  final String content;

  final TextEditingController _textController = TextEditingController();

  final AuthService _authService = AuthService();
  
  PopUp({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return 
      CupertinoAlertDialog(
      title: Text(
        title,
        style: TextStyle(fontSize: 22),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              content,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10), // Add spacing
            CupertinoTextField(
              controller: _textController,
              placeholder: "Folder name",
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
            _authService.addFolder(_textController.text),
            Navigator.of(context).pop(true),
          },
        )
      ],

    );
  }

  

  
}