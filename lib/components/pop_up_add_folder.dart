import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';

class PopUpAddFolder extends StatelessWidget {
  final TextEditingController _textController = TextEditingController();

  final AuthService _authService = AuthService();
  
  PopUpAddFolder({
    super.key,
  });

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