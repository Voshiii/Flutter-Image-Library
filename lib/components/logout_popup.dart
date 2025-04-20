import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/pages/login.dart';
// import 'package:photo_album/components/text_field.dart';

class LogoutPopup extends StatelessWidget {  
  const LogoutPopup({super.key,});

  @override
  Widget build(BuildContext context) {
    return 
      CupertinoAlertDialog(
      title: Text(
        "Are you sure you want to logout?",
        style: TextStyle(fontSize: 22),
      ),
      actions: [
        CupertinoDialogAction(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () => {
            AuthService.logout(),
            // Navigator.pop(context),
            // Navigator.pushAndRemoveUntil(
            //   context,
            //   MaterialPageRoute(builder: (context) => LoginPage()),
            //   (route) => false, // This removes all previous routes
            // )
            Navigator.pushAndRemoveUntil(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(-1.0, 0.0); // From left
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  final offsetAnimation = animation.drive(tween);

                  return SlideTransition(position: offsetAnimation, child: child);
                },
              ),
              (route) => false, // Remove all previous routes
            ),
          },
        ),
        CupertinoDialogAction(
          child: Text(
            "No",
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: () => {
            Navigator.pop(context),
          },
        )
      ],

    );
  }

  

  
}