import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_album/auth/auth.dart';
import 'package:photo_album/auth/dio.dart';

class DeleteService {
  CancelToken? _cancelToken;
  String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<dynamic> deleteFolder(String folderPath) async {
    final username = await AuthService.getUsername();
    Uri url = Uri.parse('$baseUrl/uploads/delete/folder');

    try {
      final response = await Api.dio.delete(
        url.toString(),
        data: {
          "username": username,
          "folderPath": folderPath,
        },
        options: Options(
          headers: { 
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
        ),
        cancelToken: _cancelToken
      );

      final data = response.data;
      return data;

    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return [];
      } else {
        print("Delete folder failed: $e");
        return [];
      }
    }
  }


  Future<void> deleteFile(String folderPath, String fileName) async {
    final username = await AuthService.getUsername();
    Uri url = Uri.parse('$baseUrl/uploads/delete/file');

    try {
      final response = await Api.dio.delete(
        url.toString(),
        data: {
          "username": username,
          "fileName": fileName,
          "folderPath": folderPath,
        },
        options: Options(
          headers: { 
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.json,
        ),
        cancelToken: _cancelToken
      );

      final data = response.data;
      return data;

    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        print("Delete file failed: $e");
      } else {
        print("Delete file failed: $e");
      }
    }
  }
}