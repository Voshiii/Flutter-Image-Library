import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/auth/dio.dart';

// ! REMOVE GET REQUEST BODIES

class FetchService {
  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  String baseUrl = dotenv.env['BASE_URL'] ?? '';

  final _folderController = StreamController<List<dynamic>>.broadcast();

  final _folderNameController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> fetchInstantNames(String folderName){
    fetchFileNames(folderName);
    return _folderNameController.stream;
  }
 
  // Get folder item names and metaData
  Future<void> fetchFileNames(String folderPath) async {
    final username = await AuthService.getUsername();

    final encodedPath = Uri.encodeComponent(folderPath);
    Uri url = Uri.parse('$baseUrl/uploads/names/$username/$encodedPath');

    try {
      final response = await Api.dio.get(
        url.toString(),
        options: Options(
          headers: { 
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
        ),
        cancelToken: _cancelToken
      );

      if(response.statusCode == 204){
        _folderNameController.add({});
      }
      else{
        final Map<String, dynamic> data = response.data['folderItems'];
        _folderNameController.add(data);
      }

    } 
    catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        print("Error getting file names!");
        _folderNameController.add({});
      } else {
        print("Fetch file name failed: $e");
        _folderNameController.add({});
      }
    }
  }

  Future<Map<String, dynamic>> temp() async{
    await Future.delayed(Duration(seconds: 2));
    return {};
  }

  // ! NEW
  // Get individual file data
  Future<Map<String, dynamic>> fetchFile(String folderPath, String fileName) async {
    final username = await AuthService.getUsername();

    final encodedPath = Uri.encodeComponent(folderPath);
    Uri url = Uri.parse('$baseUrl/uploads/fileContent/$username/$encodedPath/$fileName');

    // Send a GET request
    try {
      final response = await Api.dio.get(
        url.toString(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
        ),
        cancelToken: _cancelToken,
      );

      final fileInfo = response.data;
      return fileInfo;

    } 
    catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        log("Error!");
        return {};
      } else {
        log("Fetch failed: $e");
        return {};
      }
    }
  }


  // * Used to get all the files to share
  // Change this so no need for re-fetching?
  Future<List<dynamic>> fetchAllFiles(String folderName) async {
    String? username = await AuthService.getUsername();
    Uri url = Uri.parse('$baseUrl/uploads/$username/$folderName/ALL');

    // Send a GET request
    try {
      final response = await _dio.get(
        url.toString(),
        options: Options(
          headers: {
            'Accept': 'image/jpeg, image/png, video/mp4, video/quicktime',
          },
          responseType: ResponseType.bytes,
        ),
        cancelToken: _cancelToken,
      );

      if(response.statusCode == 204){
        return [];
      }

      final Uint8List bytes = response.data;
      final String jsonString = utf8.decode(bytes);
      final Map<String, dynamic> data = jsonDecode(jsonString);

      return List<dynamic>.from(data['images']);
    } 
    catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        print("Error!");
        return [];
      } else {
        // print("Fetch failed: $e");
        return [];
      }
    }
  }

  // Future<void> downloadAndSaveImage(String imageUrl) async {
  //   // Request permissions
  //   await Permission.storage.request();

  //   try {
  //     final response = await _dio.get(
  //       imageUrl,
  //       options: Options(
  //         responseType: ResponseType.bytes, // Very important!
  //       ),
  //     );

  //     if (response.statusCode == 200) {
  //       final Uint8List bytes = Uint8List.fromList(response.data);

  //       final result = await ImageGallerySaver.saveImage(bytes);
  //       log('Saved to gallery: $result');
  //     } else {
  //       log('Failed to download image: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     log('Error downloading image: $e');
  //   }
  // }


   
  void cancelUpload() {
    _cancelToken?.cancel("Upload cancelled by user");
  }

  void dispose() {
    _folderController.close();
  }

}