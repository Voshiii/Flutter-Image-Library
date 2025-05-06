import 'package:flutter/material.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/pages/home_screen.dart';
import 'package:photo_album/pages/login.dart';
import 'package:photo_album/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool loggedIn = await AuthService.isLoggedIn();
  await dotenv.load();
  runApp(
    ChangeNotifierProvider(create: (context) => ThemeProvider(),
      child: MainApp(isLoggedIn: loggedIn),
    )
  );
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;
  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        splash: 'assets/hello-hi.gif', //Add splachscreen
        splashIconSize: 2000,
        centered: true,
        nextScreen: isLoggedIn ? HomeScreen() : LoginPage(),
        duration: 1500,
      ),
      theme: themeProvider.themeData,
    );
  }
}
