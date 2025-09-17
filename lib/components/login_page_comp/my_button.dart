import 'package:flutter/material.dart';

// ! TODO rename this widget?
class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final Color color;
  final bool showShadow;


  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.color,
    required this.showShadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color.fromARGB(255, 223, 223, 223), // border color
            width: 1.5,
          ),
          boxShadow: 
          showShadow
          ? [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(1, 2),
              ),
            ]
          : [],
        ),
        
        padding: EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black
            ),
          ),
        ),
      ),
    );
  }

}