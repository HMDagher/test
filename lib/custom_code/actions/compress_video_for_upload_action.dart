// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'package:easy_video_editor/easy_video_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Compress video after the Video Editor is done.
Future<String> compressVideoForUploadAction(String videoPath) async {
  try {
    // Check if the input file exists
    final inputFile = File(videoPath);
    if (!await inputFile.exists()) {
      throw Exception('Input video file does not exist: $videoPath');
    }

    // Get the app documents directory for output
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName =
        'compressed_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final String outputPath = path.join(appDir.path, fileName);

    // Create video editor with compression
    final editor = VideoEditorBuilder(videoPath: videoPath).compress(
        resolution: VideoResolution
            .p720); // Compress to 720p for good balance of quality/size

    // Export the compressed video
    final String? compressedPath = await editor.export(
      outputPath: outputPath,
      onProgress: (progress) {
        // Optional: You can add progress tracking here if needed
        debugPrint(
            'Video compression progress: ${(progress * 100).toStringAsFixed(1)}%');
      },
    );

    if (compressedPath == null) {
      throw Exception('Video compression failed - no output path returned');
    }

    // Verify the compressed file exists
    final compressedFile = File(compressedPath);
    if (!await compressedFile.exists()) {
      throw Exception('Compressed video file was not created');
    }

    // Get file sizes for logging
    final originalSize = await inputFile.length();
    final compressedSize = await compressedFile.length();
    final compressionRatio =
        ((originalSize - compressedSize) / originalSize * 100);

    debugPrint('Video compression completed:');
    debugPrint(
        'Original size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB');
    debugPrint(
        'Compressed size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
    debugPrint('Compression ratio: ${compressionRatio.toStringAsFixed(1)}%');

    return compressedPath;
  } catch (e) {
    debugPrint('Error compressing video: $e');
    // Return original path if compression fails
    return videoPath;
  }
}
