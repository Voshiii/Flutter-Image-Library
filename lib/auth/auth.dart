import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_album/auth/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final _storage = const FlutterSecureStorage(); // Save information on device
  String baseUrl = dotenv.env['BASE_URL'] ?? ''; // API link, currently in .env (Not in GitHub)

  // ! TODO Save the token and username as variables? So no overhead to await?
  static String? currentUsername = "NOT LOGGED IN";
  static final ValueNotifier<String?> currentUsernameTest = ValueNotifier("NOT LOGGED IN");

  // ! Change this for a better confirmation to be logged in
  static Future<bool> isLoggedIn() async {
    final res = await _storage.read(key: "token") != null
    && await _storage.read(key: "username") != null;
    if(res) currentUsername = await _storage.read(key: "username");
    if(res) currentUsernameTest.value = await _storage.read(key: "username");
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
    currentUsernameTest.value = username;
  }

  // Save user email
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: 'email', value: email);
  }

  // Save faceID preferences for locking app
  static Future<void> saveFaceIDPref(bool preference) async {
    await _storage.write(key: 'activeFaceID', value: preference.toString()); // '.toString' -> can only save strings
  }

  // GETTERS

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

  // logout and remove items
  static Future<void> logout() async {
    await _storage.deleteAll();
    currentUsername = "NOT LOGGED IN";
  }

  // Return res code, title and comment -> for popup 
  Future<(int, String, String)> login(String username, String password) async {
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
        return (res.statusCode ?? 200, "", "");
      }
      
      return (res.statusCode ?? 500, "Server error", res.data.toString());
    } on DioException catch (e) {
      print("ERROR LOGGING IN ${e.response?.statusCode}: ${e.response}");
      if (e.response != null) {
        // Server responded with non-200
        return (e.response?.statusCode ?? 400, "Authentication Issue", e.response?.data.toString() ?? "Invalid username or password!");
      } else {
        // No response (e.g. network issue)
        return (500, "Server error", "Please try again later!");
      }
    }

  }

  Future<(int, String, String)> register(String email, String password, String username) async {
    try {
      final res = await Api.dio.post(
        '/register',
        data: {
        'email': email,
        'password': password,
        'username': username
      });

      if(res.statusCode == 200){
        return (res.statusCode!, "", "");
      }
      return (500, "Server error", "Please try again later!");

    } on DioException catch (e) {
      print("ERROR LOGGING IN ${e.response?.statusCode}: ${e.response}");
      if (e.response != null) {
        // Server responded with non-200
        return (e.response?.statusCode ?? 400, "Registering Issue", e.response?.data.toString() ?? "Something went wrong trying to register!");
      } else {
        // No response (e.g. network issue)
        return (500, "Server error", "Please try again later!");
      }
    }
    
  }

  static Future<bool> updateUsername(String currUsername, String newUsername) async {
    try {
      final res = await Api.dio.put(
        '/changeUsername/$currUsername',
        data: {
        'newUsername': newUsername
      });

      if(res.statusCode == 200){
        saveToken(res.data["token"]);
        Api.setAuthToken(res.data["token"]);
        return true;
      }
      return false;
    } catch (e) {
      print("ERROR CHANING USERNAME: $e");
      return false;
    }
  }

  static Future<bool> updatePassword(String currPassword, String newPassword, String username) async {
    print("THE USERNAME: $username");
    try {
      final res = await Api.dio.put(
        '/changePassword/$username',
        data: {
        'currPassword': currPassword,
        'newPassword': newPassword
      });

      if(res.statusCode == 200){
        return true;
      }
      return false;

    } catch (e) {
      print("ERROR CHANING PASSWORD: $e");
      return false;
    }
    
  }
  
}


