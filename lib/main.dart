import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_album/pages/splash_screen.dart';
import 'package:photo_album/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // Initialize local notifications
  // const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  // const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
  // const InitializationSettings initSettings = InitializationSettings(
  //   // android: androidInit,
  //   iOS: iosInit,
  // );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      ChangeNotifierProvider(create: (context) => ThemeProvider(),
        child: MainApp(),
      )
    );

    // await flutterLocalNotificationsPlugin.initialize(initSettings);
    initializeNotifications();

  });
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MySplashScreen(),
      theme: themeProvider.themeData,
    );
  }
}
