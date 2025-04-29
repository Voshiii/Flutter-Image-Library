import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_album/pages/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static String? cachedUsername;
  static String? cachedPassword;
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
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


  // Stream<List<String>> getFolders(BuildContext context) async* {
  Stream<List<dynamic>> getFolders(BuildContext context) async* {
    String? username = await getUsername();
    String? password = await getPassword();
    Uri url = Uri.parse('$baseUrl/uploads');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    try{
      // Send a GET request
      final response = await http.get(
        url,
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        // Parse the response
        final List<dynamic> data = jsonDecode(response.body)["folders"];
        yield data;
      } 
      else {
        print("Error occured while trying to fetch folders!");
        yield [];
        // throw Exception('Failed to load folders');
      }
    }
    catch(e){
      print("Exception: $e");
      yield [];
    }
  }

  Future<bool> renameFolder(String oldFolderName, String newFolderName) async {
    String? username = await getUsername();
    String? password = await getPassword();
    Uri url = Uri.parse('$baseUrl/uploads');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    
    // Send a PUT request
    final response = await http.put(
      url,
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldFolderName': oldFolderName,
        'newFolderName': newFolderName,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    }
    else{
      return false;
    }
  }

  Future<List<dynamic>> fetchImages(String folderName) async {
    String? username = await getUsername();
    String? password = await getPassword();
    Uri url = Uri.parse('$baseUrl/uploads/$folderName');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    // Send a GET request
    final response = await http.get(
      url,
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'image/jpeg',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<dynamic>.from(data['images']);
    }
    else{
      return [];
    }
  }

  void addFolder(String folderName) async {
    String? username = await getUsername();
    String? password = await getPassword();
    Uri url = Uri.parse('$baseUrl/uploads');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    // Send a POST request
    final response = await http.post(
      url,
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'folderName': folderName,
      }),
    );

    // To-DO: ADD A SUCCESS SCREEN
    if (response.statusCode == 200) {
      print("Success!");
    }
    else{
      // return [];
      print("Error updating");
      // return [];
    }
  }

  Future<void> addImage(File? image, String folderName, String imageName) async {
    try {
      String? username = await getUsername();
      String? password = await getPassword();
      Uri url = Uri.parse('$baseUrl/uploads/$folderName');
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      // Create a MultipartRequest
      var request = http.MultipartRequest('POST', Uri.parse(url.toString()));

      // Add headers
      request.headers['Authorization'] = basicAuth;

      //To-do: Check for duplicate names      
      request.fields['fileName'] = imageName;

      // Attach the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image!.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        // Parse the response
        final responseData = await http.Response.fromStream(response);
        print('Upload successful: ${responseData.body}');
      } else {
        print('Upload failed with status: ${response.statusCode}');
      }

    }
    catch (e) {
      print('Error: $e');
    }
  }

  Future<dynamic> deleteFolder(String folderName) async {
    String? username = await getUsername();
    String? password = await getPassword();
    Uri url = Uri.parse('$baseUrl/uploads/');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    // Send a POST request
    final response = await http.delete(
      url,
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'folderName': folderName,
      }),
    );

    // ADD A SUCCESS SCREEN
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
      // return List<String>.from(data['images']);
    }
    else{
      print("Error Deleting");
      return {};
      // return [];
    }
  }


  Future<void> deleteImage(String folderName, String imgName) async {
    String? username = await getUsername();
    String? password = await getPassword();
    Uri url = Uri.parse('$baseUrl/uploads/$folderName');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    // Send a POST request
    final response = await http.delete(
      url,
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'folderName': folderName,
        'fileName': imgName,
      }),
    );

    // To-Do: ADD A SUCCESS SCREEN
    if (response.statusCode == 200) {
      print("Success!");
    }
    else{
      print("Error Deleting");
      // return [];
    }
  }

}


