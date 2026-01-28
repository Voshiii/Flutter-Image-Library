import 'package:flutter/material.dart';

// ! TODO rename this widget?
class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final Color color;
  final bool showShadow;
  final bool reverseAnimation;


  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.color,
    required this.showShadow,
    this.reverseAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
          // Ability to add a slide animation if two text values are added
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) {
              Animation<Offset> inAnimation = Tween<Offset>(
                begin: const Offset(2, 0), // new text comes from right
                end: Offset.zero,
              ).animate(animation);
              Animation<Offset> outAnimation = Tween<Offset>(
                // begin: Offset.zero,
                begin: const Offset(-2, 0),
                end: Offset.zero, // old text slides left
              ).animate(animation);

              if(reverseAnimation){
                inAnimation = Tween<Offset>(
                  begin: const Offset(-2, 0), // new text comes from right
                  end: Offset.zero,
                ).animate(animation);

                outAnimation = Tween<Offset>(
                  // begin: Offset.zero,
                  begin: const Offset(2, 0),
                  end: Offset.zero, // old text slides left
                ).animate(animation);
              }
              return ClipRect(
                child: SlideTransition(
                  position: child.key == ValueKey(text) ? inAnimation : outAnimation,
                  child: child,
                ),
              );
            },
            child: Text(
              text,
              key: ValueKey(text),
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

}