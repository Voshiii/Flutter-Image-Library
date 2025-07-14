import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_album/pages/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_album/services/fetch_service.dart';

class AuthService {
  static final _storage = const FlutterSecureStorage();
  String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  static Future<bool> isLoggedIn() async {
    return await _storage.read(key: 'username') != null 
    && await _storage.read(key: 'password') != null;
  }

  // GETTERS
  static Future<String?> getUsername() async {
    return await _storage.read(key: 'username');
  }

  static Future<String?> getPassword() async {
    return await _storage.read(key: 'password');
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  void login(String username, String password, BuildContext context) async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    // Define the URL
    Uri url = Uri.parse('$baseUrl/auth');

    // Send GET request
    final response = await http.get(
      url,
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
    );

    // Handle response
    if (response.statusCode == 200) {
      await saveCredentials(username, password);

      // final responseData = getFolders();
      final responseData = FetchService().fetchInstantFolder();
      await Future.delayed(Duration(seconds: 2));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(folderStream: responseData,)),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => createDialog(context),
      );
    }
  }

  Widget createDialog(BuildContext context) => CupertinoAlertDialog(
    title: Text(
      "Invalid Credentials",
      style: TextStyle(fontSize: 22),
    ),
    content: Text(
      "Username or Passowrd Incorrect",
      style: TextStyle(fontSize: 16),
    ),
    actions: [
      CupertinoDialogAction(
        child: Text(
          "Ok",
          style: TextStyle(color: Colors.blue),
        ),
        onPressed: () => Navigator.pop(context),
      )
    ],

  );
  
}


