import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:photo_album/services/fetch_service.dart';

class FileCacheHelper {
  static Map<String, String> cachedData = {}; // fileName -> bytes

  // Download file if not cached, return raw bytes
  static Future<Uint8List> getFileData(String fileName, String folderPath) async {
    print("Searching for: $fileName");

    // Data is already in the cache
     String? filePath = cachedData[fileName];

    // If in cache, try reading from cached path
    if (filePath != null) {
      final file = File(filePath);
      if (await file.exists()) {
        print("In cache");
        return await file.readAsBytes();
      } else {
        // Path in cache but file got deleted, remove entry
        cachedData.remove(fileName);
      }
    }

    // Check if file exists on disk
    final dir = await getApplicationDocumentsDirectory();
    filePath = '${dir.path}/$fileName';
    final file = File(filePath);

    if (await file.exists()) {
      cachedData[fileName] = filePath;
      print("In disk");
      return await file.readAsBytes();
    }

    print("Not in cache, calling fetch function");
    final response = await FetchService().fetchFile(folderPath,fileName);
    if (response.isNotEmpty) {
      final base64Str = response["data"] as String;
      final Uint8List bytes = base64Decode(base64Str);

      await file.writeAsBytes(bytes);

      cachedData[fileName] = filePath;
      return bytes;
    }


    // return null;
    // TODO Check if this works
    return Uint8List(0);
  }
}
