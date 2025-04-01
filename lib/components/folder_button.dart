import 'package:flutter/material.dart';
// import 'package:photo_album/components/my_delete_popup.dart';

class MyFolderButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onLongPress;


  const MyFolderButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.onLongPress,
    });

  // bool _isLongPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,

      child: Material(

        child: InkWell(
          onTap: onTap,
          // splashColor: const Color.fromARGB(255, 198, 198, 198),
          // highlightColor: const Color.fromARGB(255, 198, 198, 198),
          splashColor: const Color.fromARGB(255, 138, 186, 198),
          highlightColor: const Color.fromARGB(255, 167, 215, 227),
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              // color: Theme.of(context).colorScheme.secondary,
              color: const Color.fromARGB(255, 231, 231, 231),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder,
                    size: 50,
                    color: Colors.blue,
                  ),
                  Text(text)
                ],  
              ),
            ),
          ),
        ),
      ),
      
    );
  }
}