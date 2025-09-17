import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget errorDialog(BuildContext context, String title, String content) => CupertinoAlertDialog(
  title: Text(
    title,
    style: TextStyle(fontSize: 22),
  ),
  content: Text(
    content,
    style: TextStyle(fontSize: 16),
  ),
  actions: [
    CupertinoDialogAction(
      child: Text(
        "Ok",
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      onPressed: () => Navigator.pop(context),
    )
  ],
);