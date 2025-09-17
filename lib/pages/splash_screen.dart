import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/components/push_homescreen.dart';
import 'package:photo_album/pages/login_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

//! TODO: When the names are loaded, try getting the data already

class SplashScreenState extends State<MySplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  // final FetchService _fetchService = FetchService();

  // ! REMOVE FOR PROD, USED TO REMOVE SPLASHSCREEN WAIT
  // bool _removeSplashScreen = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _loadDataAndLogin();
  }

  Future<void> _loadDataAndLogin() async {
    bool loggedIn = await AuthService.isLoggedIn();
    // print("Is logged in: $loggedIn");

    if(!loggedIn){
      await AuthService.saveFaceIDPref(false);

      // if(!_removeSplashScreen){
      //   await Future.delayed(Duration(seconds: 2));
      // }
      
      if(!mounted) return;

      // Navigate to Login page if not logged in
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => LoginPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 800),
        ),
      );
    }
    else{
      // Navigate to homescreen if already logged in
      if(!mounted) return;
      pushToHomeScreen(context, "Fade");

    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF38B6FF),
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: Image.asset('assets/SplashScreenImg.png', height: 400),
        ),
      ),
    );
  }
}
