import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/auth/dio.dart';

class UploadService {
  CancelToken? _cancelToken;
  String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<bool> uploadFile({
    required File file, 
    required String folderPath, 
    required String imageName, 
    required Function(double) onProgress,
  }) async {
    _cancelToken = CancelToken();
    final username = await AuthService.getUsername();
    Uri url = Uri.parse('$baseUrl/uploads/item/$username');

    try {
      FormData formData = FormData.fromMap({
        'fileName': imageName,
        'file': await MultipartFile.fromFile(file.path, filename: imageName),
        'folderPath': folderPath,
      });

      await Api.dio.post(
        url.toString(),
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            },
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

// ! GET BACK TO THIS: MAKE SURE TO ONLY UPLOAD TO THE CORRECT USER, NO OTHER USER CAN UPLOAD TO THE USERNAME
  void cancelUpload() {
    print("Canelled by user....");
    _cancelToken?.cancel("Upload cancelled by user");
  }

  void addFolder(String folderName, String folderPath) async {
    final username = await AuthService.getUsername();
    Uri url = Uri.parse('$baseUrl/uploads/$username');

    final data = {
      'folderName': folderName,
      'folderPath': folderPath,
    };

    await Api.dio.post(
      url.toString(),
      data: data,
      options: Options(
        headers: { 
          'Content-Type': 'application/json',
        }
      ),
    );
  }

  // ? Put this in another file?
  Future<bool> renameItem(String oldItemName, String newItemName, String folderPath) async {
    final username = await AuthService.getUsername();
    Uri url = Uri.parse('$baseUrl/uploads/$username/rename');
    
    // Send a PUT request
    try {
      await Api.dio.put(
        url.toString(),
        data: jsonEncode({
        'oldItemName': oldItemName,
        'newItemName': newItemName,
        'folderPath': folderPath,
      }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          }
        ),
        cancelToken: _cancelToken,
      );
      return true;
    } 
    catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return false;
      } else {
        print("Rename failed: $e");
        return false;
      }
    }
  }

}