import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/services/upload_service.dart';

class PopUpRenameItem extends StatefulWidget {
  final String oldFileName;
  final String currentFilePath;
  final bool isFile;

   const PopUpRenameItem({
    super.key,
    required this.oldFileName,
    required this.currentFilePath,
    required this.isFile,
  });

  @override
  State<PopUpRenameItem> createState() => _PopUpRenameItemState();
}

class _PopUpRenameItemState extends State<PopUpRenameItem> {
  final TextEditingController _textController = TextEditingController();
  final UploadService _uploadService = UploadService();
  bool _isOkEnabled = true;

  @override
  void initState() {
    super.initState();
    if(widget.isFile){
      _textController.text = widget.oldFileName.substring(0, widget.oldFileName.length - 8);
    }
    else{
      _textController.text = widget.oldFileName;
    }
 
    final text = _textController.text.trim();
    _isOkEnabled = !(text.isEmpty || text == widget.oldFileName);
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
      if(widget.isFile){
        // Remove .enc and ext
        _isOkEnabled = !(text.isEmpty || text == widget.oldFileName.substring(0, widget.oldFileName.length - 8));
      }
      else{
        _isOkEnabled = !(text.isEmpty || text == widget.oldFileName);
      }
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
              "Please enter new folder name for ${widget.oldFileName.substring(0, widget.oldFileName.length - 4)}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            
            CupertinoTextField(
              controller: _textController,
              placeholder: "New folder name",
              maxLines: null,
              minLines: 1,
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
          onPressed: !_isOkEnabled
          ? null
          : () async {
            final bool result = await _uploadService.renameItem(widget.oldFileName, _textController.text, widget.currentFilePath);
            if(!context.mounted) return;
            if (result == false) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to rename folder!')),
              );
            }
      
            Navigator.of(context).pop(result);
          },
          child: Text(
            "Ok",
            style: widget.isFile
            ? !(_textController.text.isEmpty || _textController.text == widget.oldFileName.substring(0, widget.oldFileName.length - 8))
              ? TextStyle(color: Theme.of(context).colorScheme.primary)
              : TextStyle(color: const Color.fromARGB(255, 138, 138, 138))
            : _isOkEnabled && _textController.text != widget.oldFileName
              ? TextStyle(color: Theme.of(context).colorScheme.primary)
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