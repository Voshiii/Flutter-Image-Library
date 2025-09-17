import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfThumbnail extends StatefulWidget {
  final String path;

  const PdfThumbnail({super.key, required this.path});

  @override
  State<PdfThumbnail> createState() => _PdfThumbnailState();
}

class _PdfThumbnailState extends State<PdfThumbnail> {
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    final doc = await PdfDocument.openFile(widget.path); // Open the pdf
    final page = await doc.getPage(1); // Get the first page of the pdf
    final pageImage = await page.render(
      width: page.width,
      height: page.height,
      format: PdfPageImageFormat.png,
    );
    await page.close(); // Close the pdf again

    setState(() {
      imageBytes = pageImage!.bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: imageBytes == null
          ? const Center(child: CircularProgressIndicator())
          : Image.memory(imageBytes!, fit: BoxFit.fitHeight),
    );
  }
}
