import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> saveImageToGallery(String base64String) async {
  // Decode Base64 to Uint8List
  Uint8List bytes = base64Decode(base64String);

  // Request permission (iOS needs this)
  var status = await Permission.photosAddOnly.request();
  if (status.isGranted) {
    final result = await ImageGallerySaver.saveImage(bytes);
    if (result['isSuccess']) {
      print("Image saved to gallery successfully!");
    } else {
      print("Failed to save image.");
    }
  } else {
    print("Permission denied.");
    await requestPermission();
  }
}

Future<void> requestPermission() async {
  PermissionStatus status = await Permission.photosAddOnly.request();

  if (status.isGranted) {
    print("Permission granted for adding photos!");
  } else if (status.isDenied) {
    print("Permission denied.");
  } else if (status.isPermanentlyDenied) {
    print("Permission permanently denied. Open settings.");
    openAppSettings(); // Opens the settings page
  }
}
