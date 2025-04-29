import 'dart:io';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

void shareImages(List<Uint8List> imageBytesList) async {
  final tempDir = await getTemporaryDirectory();
  List<XFile> xFiles = [];

  for (int i = 0; i < imageBytesList.length; i++) {
    final file = File('${tempDir.path}/image_$i.png');
    await file.writeAsBytes(imageBytesList[i]);
    xFiles.add(XFile(file.path));
  }

  if (xFiles.isNotEmpty) {
    await Share.shareXFiles(xFiles);
  }
}
