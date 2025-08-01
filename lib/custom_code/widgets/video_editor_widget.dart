// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:easy_video_editor/easy_video_editor.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

class VideoEditorWidget extends StatefulWidget {
  const VideoEditorWidget({
    super.key,
    this.width,
    this.height,
    this.videoPath,
    this.onVideoEditingComplete,
    this.onCloseEditor,
  });

  final double? width;
  final double? height;
  final String? videoPath; // Video path from camera widget
  final Future<dynamic> Function(String editedVideoPath)?
      onVideoEditingComplete;
  final Future<dynamic> Function()? onCloseEditor;

  @override
  State<VideoEditorWidget> createState() => _VideoEditorWidgetState();
}

class _VideoEditorWidgetState extends State<VideoEditorWidget> {
  VideoPlayerController? _videoController;
  bool _isProcessing = false;
  String? _processedVideoPath;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(VideoEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoPath != oldWidget.videoPath && widget.videoPath != null) {
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    if (widget.videoPath == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Use original video
      _processedVideoPath = widget.videoPath!;
      await _initializeVideoPlayer();
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _handleError('Error initializing video: $e');
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_processedVideoPath == null) return;

    try {
      // Initialize video player with processed video
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(_processedVideoPath!));
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.play();

      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      throw Exception('Video player initialization failed: $e');
    }
  }

  void _handleError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: FlutterFlowTheme.of(context).error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoPath == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No video selected',
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Record a video using the camera',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Full-screen video preview
          if (_videoController != null && _videoController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),

          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Loading video...',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),

          // Control buttons overlay
          if (!_isProcessing)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button with frosted glass
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () async {
                            if (widget.onCloseEditor != null) {
                              await widget.onCloseEditor!();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  // Done button with frosted glass
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () async {
                            if (widget.onVideoEditingComplete != null &&
                                _processedVideoPath != null) {
                              await widget.onVideoEditingComplete!(
                                  _processedVideoPath!);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
