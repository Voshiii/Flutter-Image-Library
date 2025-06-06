import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_album/auth/auth.dart';

class FetchService {
  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  String baseUrl = dotenv.env['BASE_URL'] ?? '';

  // Private constructor
  FetchService._internal();

  // The singleton instance
  static final FetchService _instance = FetchService._internal();

  // Factory constructor returns the same instance
  factory FetchService() => _instance;

  final _folderController = StreamController<List<dynamic>>.broadcast();

  Stream<List<dynamic>> fetchInstantFolder() {
    // Start fetching instantly
    getFolders();
    return _folderController.stream;
  }

  Future<void> getFolders() async {
    String? username = await AuthService.getUsername();
    String? password = await AuthService.getPassword();
    Uri url = Uri.parse('$baseUrl/uploads');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    try {
      final response = await _dio.get(
        url.toString(),
        options: Options(
          headers: {'Authorization': basicAuth},
        ),
        cancelToken: _cancelToken,
      );

      final List<dynamic> data = response.data['folders'];
      _folderController.add(data);
    } 
    catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        print("Error!");
      } else {
        print("Fetch failed: $e");
      }
      _folderController.add([]);
    }
  }
 

  // Change to "fetchFiles"
  Future<List<dynamic>> fetchImages(String folderName) async {
    String? username = await AuthService.getUsername();
    String? password = await AuthService.getPassword();
    Uri url = Uri.parse('$baseUrl/uploads/$folderName');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    // Send a GET request
    try {
      final response = await _dio.get(
        url.toString(),
        options: Options(
          headers: {
            'Authorization': basicAuth,
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
        print("Fetch failed: $e");
        return [];
      }
    }
  }

   
  void cancelUpload() {
    _cancelToken?.cancel("Upload cancelled by user");
  }

  void dispose() {
    _folderController.close();
  }

}