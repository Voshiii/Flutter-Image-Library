import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/pages/home_screen.dart';
import 'package:photo_album/pages/login.dart';

class MySplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<MySplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AuthService _authService = AuthService();

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

    if(!loggedIn){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
    else{
      // Start fetching data immediately
      Stream<List<dynamic>> responseData = _authService.fetchInstantFolder();

      // Wait for animation to finish too
      await Future.delayed(Duration(seconds: 2));

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => HomeScreen(folderStream: responseData),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 800),
        ),
      );


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
