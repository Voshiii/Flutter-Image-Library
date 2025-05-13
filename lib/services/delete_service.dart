import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:photo_album/auth/auth.dart';

class DeleteService {
  final Dio _dio = Dio();
  CancelToken? _cancelToken;
  String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<dynamic> deleteFolder(String folderName) async {
    String? username = await AuthService.getUsername();
    String? password = await AuthService.getPassword();
    Uri url = Uri.parse('$baseUrl/uploads/');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    try {
      final response = await _dio.delete(
        url.toString(),
        data: jsonEncode({'folderName': folderName}),
        options: Options(
          headers: {
            'Authorization': basicAuth,
          },
        ),
        cancelToken: _cancelToken,
      );

      final data = response.data;
      return data;

    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        return [];
      } else {
        print("Delete failed: $e");
        return [];
      }
    }
  }


  Future<void> deleteImage(String folderName, String imgName) async {
    String? username = await AuthService.getUsername();
    String? password = await AuthService.getPassword();
    Uri url = Uri.parse('$baseUrl/uploads/$folderName');
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    try {
      final response = await _dio.delete(
        url.toString(),
        data: jsonEncode({
          'folderName': folderName,
          'fileName': imgName,
        }),
        options: Options(
          headers: {
            'Authorization': basicAuth,
          },
        ),
        cancelToken: _cancelToken,
      );

      final data = response.data;
      return data;

    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        // return [];
        print("Cancelled?");
      } else {
        print("Delete failed: $e");
        // return [];
      }
    }
  }
}