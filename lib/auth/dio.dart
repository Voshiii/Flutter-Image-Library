import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Api {
  static final Dio dio = Dio(BaseOptions(baseUrl: dotenv.env['BASE_URL'] ?? ''));

  static Future<void> setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
    return Future.value();
  }
}
