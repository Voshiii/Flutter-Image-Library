import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:photo_album/pages/splash_screen.dart';
import 'package:photo_album/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    ChangeNotifierProvider(create: (context) => ThemeProvider(),
      child: MainApp(),
    )
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        splash: 'assets/hello-hi.gif',
        splashIconSize: 2000,
        centered: true,
        nextScreen: MySplashScreen(),
        duration: 1500,
        // splashTransition: SplashTransition.rotationTransition,
        pageTransitionType: PageTransitionType.fade,
      ),
      // home: MySplashScreen(),
      theme: themeProvider.themeData,
    );
  }
}
