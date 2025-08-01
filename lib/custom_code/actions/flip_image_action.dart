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
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Flip the Image horizontally.
Future<String> flipImageAction(String imagePath) async {
  try {
    // Check if the input file exists
    final inputFile = File(imagePath);
    if (!await inputFile.exists()) {
      throw Exception('Input image file does not exist: $imagePath');
    }

    // Read the image bytes
    final Uint8List imageBytes = await inputFile.readAsBytes();

    // Flip the image horizontally
    final Uint8List flippedBytes = await _flipImageHorizontally(imageBytes);

    // Get the app documents directory for output
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName =
        'flipped_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String outputPath = path.join(appDir.path, fileName);

    // Write the flipped image
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(flippedBytes);

    // Verify the flipped file exists
    if (!await outputFile.exists()) {
      throw Exception('Flipped image file was not created');
    }

    debugPrint('Image flipping completed: $outputPath');
    return outputPath;
  } catch (e) {
    debugPrint('Error flipping image: $e');
    // Return original path if flipping fails
    return imagePath;
  }
}

// Helper function to flip image horizontally
Future<Uint8List> _flipImageHorizontally(Uint8List imageBytes) async {
  final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  final ui.Image image = frameInfo.image;

  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  // Apply horizontal flip transformation
  canvas.scale(-1.0, 1.0);
  canvas.translate(-image.width.toDouble(), 0);
  canvas.drawImage(image, Offset.zero, Paint());

  final ui.Picture picture = recorder.endRecording();
  final ui.Image flippedImage =
      await picture.toImage(image.width, image.height);
  final ByteData? byteData =
      await flippedImage.toByteData(format: ui.ImageByteFormat.png);

  image.dispose();
  flippedImage.dispose();
  picture.dispose();

  return byteData!.buffer.asUint8List();
}
