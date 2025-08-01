// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Compress images after the Image Editor is done.
Future<String> compressImageForUploadAction(String imagePath) async {
  try {
    // Check if the input file exists
    final inputFile = File(imagePath);
    if (!await inputFile.exists()) {
      throw Exception('Input image file does not exist: $imagePath');
    }

    // Read the image file
    final Uint8List imageBytes = await inputFile.readAsBytes();

    // Decode the image
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Get original dimensions
    final originalWidth = image.width;
    final originalHeight = image.height;

    // Calculate new dimensions (max 1920x1920 for upload, maintaining aspect ratio)
    const int maxDimension = 1920;
    int newWidth = originalWidth;
    int newHeight = originalHeight;

    if (originalWidth > maxDimension || originalHeight > maxDimension) {
      if (originalWidth > originalHeight) {
        newWidth = maxDimension;
        newHeight = (originalHeight * maxDimension / originalWidth).round();
      } else {
        newHeight = maxDimension;
        newWidth = (originalWidth * maxDimension / originalHeight).round();
      }

      // Resize the image
      image = img.copyResize(image, width: newWidth, height: newHeight);
    }

    // Compress the image to JPEG with quality 85 (good balance of quality/size)
    final Uint8List compressedBytes =
        Uint8List.fromList(img.encodeJpg(image, quality: 85));

    // Get the app documents directory for output
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName =
        'compressed_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String outputPath = path.join(appDir.path, fileName);

    // Write the compressed image
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(compressedBytes);

    // Get file sizes for logging
    final originalSize = imageBytes.length;
    final compressedSize = compressedBytes.length;
    final compressionRatio =
        ((originalSize - compressedSize) / originalSize * 100);

    debugPrint('Image compression completed:');
    debugPrint('Original dimensions: ${originalWidth}x${originalHeight}');
    debugPrint('Compressed dimensions: ${newWidth}x${newHeight}');
    debugPrint('Original size: ${(originalSize / 1024).toStringAsFixed(2)} KB');
    debugPrint(
        'Compressed size: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
    debugPrint('Compression ratio: ${compressionRatio.toStringAsFixed(1)}%');

    return outputPath;
  } catch (e) {
    debugPrint('Error compressing image: $e');
    // Return original path if compression fails
    return imagePath;
  }
}
