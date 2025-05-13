import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_album/auth/auth.dart';

class UploadService {
  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<bool> uploadFile({
    required File file, 
    required String folderName, 
    required String imageName, 
    required Function(double) onProgress
  }) async {
    _cancelToken = CancelToken();
    String? username = await AuthService.getUsername();
    String? password = await AuthService.getPassword();
    Uri url = Uri.parse('$baseUrl/uploads/$folderName');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    try {
      FormData formData = FormData.fromMap({
        'fileName': imageName,
        'file': await MultipartFile.fromFile(file.path, filename: imageName),
      });

      await _dio.post(
        url.toString(),
        data: formData,
        options: Options(
          headers: {'Authorization': basicAuth},
        ),
        cancelToken: _cancelToken,
        onSendProgress: (int sent, int total) {
          double progress = sent / total;
          onProgress(progress);
        },
      );

      return true;
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return false;
      } else {
        print("Upload failed: $e");
        return false;
      }
    }
  }

  void cancelUpload() {
    _cancelToken?.cancel("Upload cancelled by user");
  }

  void addFolder(String folderName) async {
    String? username = await AuthService.getUsername();
    String? password = await AuthService.getPassword();
    Uri url = Uri.parse('$baseUrl/uploads');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    // Send a POST request
    try {
      await _dio.post(
        url.toString(),
        data: jsonEncode({
          'folderName': folderName,
        }),
        options: Options(
          headers: {'Authorization': basicAuth},
        ),
        cancelToken: _cancelToken,
      );
    } 
    catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        print("Error!");
      } else {
        print("Upload failed: $e");
      }
    }
  }

  Future<bool> renameFolder(String oldFolderName, String newFolderName) async {
    String? username = await AuthService.getUsername();
    String? password = await AuthService.getPassword();
    Uri url = Uri.parse('$baseUrl/uploads');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    
    // Send a PUT request
    try {
      await _dio.put(
        url.toString(),
        data: jsonEncode({
        'oldFolderName': oldFolderName,
        'newFolderName': newFolderName,
      }),
        options: Options(
          headers: {'Authorization': basicAuth},
        ),
        cancelToken: _cancelToken,
      );
      return true;
    } 
    catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return false;
      } else {
        print("Upload failed: $e");
        return false;
      }
    }

  }

}
