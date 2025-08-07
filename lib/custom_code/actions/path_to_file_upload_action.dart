// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;

/// Converts a local file path into an FFUploadedFile.
Future<FFUploadedFile?> pathToFileUploadAction(String localPath) async {
  if (localPath.isEmpty) return null;

  try {
    final file = File(localPath);
    if (!await file.exists()) {
      print('File does not exist: $localPath');
      return null;
    }

    final fileName = p.basename(localPath);
    final bytes = await file.readAsBytes();

    print(
        'File converted: $fileName (${(bytes.length / 1024).toStringAsFixed(2)} KB)');

    return FFUploadedFile(name: fileName, bytes: bytes);
  } catch (e) {
    print('Error in pathToFileUploadAction: $e');
    return null;
  }
}
