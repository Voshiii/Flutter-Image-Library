import 'dart:ui';
import 'package:flutter/material.dart';

class MyFolderButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;


  const MyFolderButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.backgroundColor,
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              // color: const Color.fromARGB(255, 231, 231, 231),
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder,
                    size: 65,
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