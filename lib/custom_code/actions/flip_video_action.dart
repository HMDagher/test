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

/// Flip the Video horizontally.
Future<String> flipVideoAction(String videoPath) async {
  try {
    // Check if the input file exists
    final inputFile = File(videoPath);
    if (!await inputFile.exists()) {
      throw Exception('Input video file does not exist: $videoPath');
    }

    // Get the app documents directory for output
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName =
        'flipped_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final String outputPath = path.join(appDir.path, fileName);

    // Create video editor with horizontal flip
    final editor = VideoEditorBuilder(videoPath: videoPath)
        .flip(flipDirection: FlipDirection.horizontal);

    // Export the flipped video
    final String? flippedPath = await editor.export(
      outputPath: outputPath,
    );

    if (flippedPath == null) {
      throw Exception('Video flipping failed - no output path returned');
    }

    // Verify the flipped file exists
    final flippedFile = File(flippedPath);
    if (!await flippedFile.exists()) {
      throw Exception('Flipped video file was not created');
    }

    debugPrint('Video flipping completed: $flippedPath');
    return flippedPath;
  } catch (e) {
    debugPrint('Error flipping video: $e');
    // Return original path if flipping fails
    return videoPath;
  }
}
