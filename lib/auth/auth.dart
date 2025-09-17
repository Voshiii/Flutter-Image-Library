import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_album/auth/dio.dart';
import 'package:photo_album/components/push_homescreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final _storage = const FlutterSecureStorage(); // Save information on device
  String baseUrl = dotenv.env['BASE_URL'] ?? ''; // API link, currently in .env (Not in GitHub)

  // ! Save the token and username as variables? So no overhead to await?
  static String? currentUsername = "NOT LOGGED IN";

  // ! Change this for a better confirmation to be logged in
  static Future<bool> isLoggedIn() async {
    final res = await _storage.read(key: "token") != null
    && await _storage.read(key: "username") != null;
    if(res) currentUsername = await _storage.read(key: "username");
    return res;
    
    // ! REMOVE THIS FOR PROD
    // return true;
  }

  // Save JWT token for API requests
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  // Save the username
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: 'username', value: username);
    currentUsername = username;
  }

  // Save user email
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: 'email', value: email);
  }

  // Save faceID preferences for locking app
  static Future<void> saveFaceIDPref(bool preference) async {
    await _storage.write(key: 'activeFaceID', value: preference.toString()); // '.toString' -> can only save strings
  }
  
  // Get username
  static Future<String?> getUsername() async {
    return await _storage.read(key: 'username');
  }

  // Get JWT API token for API requests
  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Get user email
  static Future<String?> getEmail() async {
    return await _storage.read(key: 'email');
  }

  // Get faceID preferences to lock app
  static Future<bool> getFaceIdPref() async {
    return await _storage.read(key: 'activeFaceID') == "true";
  }

  // Delete all saved items
  static Future<void> clearTokenandUsername() async {
    await _storage.delete(key: "token");
    await _storage.delete(key: "username");
    await _storage.delete(key: "email");
    await _storage.delete(key: "activeFaceID");
    currentUsername = "NOT LOGGED IN";
  }

  // logout and remove items
  static Future<void> logout() async {
    await _storage.deleteAll();
    currentUsername = "NOT LOGGED IN";
  }

  Future<int?> login(String username, String password, BuildContext context) async {
    try {
      final res = await Api.dio.post(
        '/login',
        data: {
        'username': username,
        'password': password,
        }
      );

      // If login success, save information to device
      if (res.statusCode == 200) {
        final token = res.data['token'];
        final email = res.data['email'];
        await saveToken(token);
        await saveUsername(username);
        await saveEmail(email);
        await Api.setAuthToken(token);
        return res.statusCode;
      } 
      
      return res.statusCode;
    } on DioException catch (e) {
      print("ERROR LOGGING IN: $e");
      if (e.response != null) {
        // Server responded with non-200
        return e.response?.statusCode ?? 500;
      } else {
        // No response (e.g. network issue)
        return 500;
      }
    }

  }

  Future<void> register(String email, String password, String username, BuildContext context) async {
    try {
      final res = await Api.dio.post(
        '/register',
        data: {
        'email': email,
        'password': password,
        'username': username
      });

      // Handle response and save information
      if (res.statusCode == 200) {
        final token = res.data['token'];
        await saveToken(token);
        await saveUsername(username);
        await saveEmail(email);
        await Api.setAuthToken(token);

        if(!context.mounted) return;
        pushToHomeScreen(context, "");
      }
    } catch (e) {
      print("ERROR REGISTERING: $e");
    }
    
  }
  
}


