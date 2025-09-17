import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText; // bool to hide password
  final TextEditingController controller;
  final List<String>? autofillHints; // input saved password
  final List<TextInputFormatter>? inputFormatter; // can be used to limit number of words
  
  const MyTextfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.autofillHints,
    this.inputFormatter,
});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration:
        BoxDecoration(
          color: const Color.fromARGB(24, 255, 255, 255),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 1,
              offset: Offset(1, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextFormField(
          obscureText: obscureText, // hide passwords if true
          controller: controller,
          autofillHints: autofillHints, // used to autofill saved passwords
          inputFormatters: inputFormatter, // can be used to limit number of words
          onEditingComplete: () {
            FocusScope.of(context).unfocus(); // dismiss keyboard
          },
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: controller.text.isEmpty ? Colors.red : Theme.of(context).colorScheme.tertiary,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                // color: Theme.of(context).colorScheme.secondary,
                color: const Color.fromARGB(255, 223, 223, 223),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            // fillColor: Theme.of(context).colorScheme.secondary,
            fillColor: const Color.fromARGB(5, 0, 0, 0),
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: const Color.fromARGB(255, 215, 215, 215)),
          ),
        ),
      ),
    );
  }
}
