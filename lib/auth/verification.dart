

import 'package:dio/dio.dart';
import 'package:photo_album/auth/dio.dart';

Future<void> sendVerificationCode(String username) async {
  try {
      await Api.dio.post(
        '/sendVerifyCode/$username',
      );

    } on DioException catch (e) {
      print("Error sending verification code: $e");
    }
}

Future<bool> verifyCode(String code, String username) async {

  if(code.length != 4) return false;

  try {
      final res = await Api.dio.post(
        '/verifyCode/$username',
        data: {
          'code': code,
        }
      );

      if (res.statusCode == 200) {

        return true;
      }
      
      return false;
    } on DioException catch (e) {
      print("Error verifying: $e");
      if (e.response != null) {
        // Server responded with non-200
        return false;
      } else {
        // No response (e.g. network issue)
        return false;
      }
    }
}