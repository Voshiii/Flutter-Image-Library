import 'package:flutter/material.dart';
import 'package:photo_album/services/delete_service.dart';

class MyDeleteDialog extends StatefulWidget {
  final String fileName;
  final String filePath;

  const MyDeleteDialog({super.key, 
    required this.fileName,
    required this.filePath,
  });

  @override
  MyDeleteDialogState createState() => MyDeleteDialogState();
}

class MyDeleteDialogState extends State<MyDeleteDialog> {
  final DeleteService _deleteService = DeleteService();
  dynamic data;

  removeExt(String fileName){
    if (fileName.endsWith('.enc')) {
      return fileName.substring(0, fileName.length - 4); // remove ".enc"
    }
    return fileName;
  }

  bool isFile(String name) => name.contains('.') && !name.startsWith('.');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Are you sure you want to delete ",
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  TextSpan(
                    text: removeExt(widget.fileName),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22,),
                  ),
                  TextSpan(
                    text: "?",
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                ],
              ),),
        ]),
        
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 214, 214, 214),
                borderRadius: BorderRadius.circular(10),  
              ),
              child: TextButton(
                onPressed: () async {
                  if (!isFile(widget.fileName)) {
                    // FOLDER DELETION
                    await _deleteService.deleteFolder("${widget.filePath}/${widget.fileName}").then((data) {
                      if (!context.mounted) return;

                      if (data != null && data.isNotEmpty && !data["success"]) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error deleting folder! Folder must be empty.')),
                        );
                        Navigator.of(context).pop(false);
                      } else {
                        if (context.mounted) {
                          Navigator.of(context).pop(true); // Close the dialog if successful
                        }
                      }
                    });
                  } else {
                    // FILE DELETION
                    await _deleteService.deleteFile(widget.filePath, widget.fileName);
                    await Future.delayed(const Duration(seconds: 1));

                    if (!context.mounted) return;
                    Navigator.of(context).pop(true);
                  }
                },
                child: Text(
                  "Delete",
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
              ),
            ),
            
            SizedBox(width: 20,),

            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 214, 214, 214),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                }, 
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black, fontSize: 15),
                )
              ),
            ),
          ],
        )
      ],
    );
  }
}
