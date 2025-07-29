// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:easy_video_editor/easy_video_editor.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoEditorWidget extends StatefulWidget {
  const VideoEditorWidget({
    super.key,
    this.width,
    this.height,
    this.videoPath,
    this.isFrontCamera,
    this.isAndroid,
    this.onVideoEdited,
    this.onError,
  });

  final double? width;
  final double? height;
  final String? videoPath; // Video path from camera widget
  final bool? isFrontCamera; // Whether video was captured with front camera
  final bool? isAndroid; // Whether running on Android platform
  final Future<dynamic> Function(String editedVideoPath)? onVideoEdited;
  final Future<dynamic> Function(String error)? onError;

  @override
  State<VideoEditorWidget> createState() => _VideoEditorWidgetState();
}

class _VideoEditorWidgetState extends State<VideoEditorWidget> {
  VideoPlayerController? _videoController;
  bool _isProcessing = false;
  double _processingProgress = 0.0;
  String? _processedVideoPath;

  // Auto-flip detection
  bool _shouldAutoFlip = false;

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
      // Determine if video should be flipped (Android front camera only)
      _shouldAutoFlip = _shouldFlipVideo();

      if (_shouldAutoFlip) {
        // Process the video (flip it)
        await _processVideo();
      } else {
        // Use original video
        _processedVideoPath = widget.videoPath!;
        await _initializeVideoPlayer();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _handleError('Error initializing video: $e');
    }
  }

  bool _shouldFlipVideo() {
    // Only flip front camera videos on Android
    final isFrontCamera = widget.isFrontCamera ?? false;
    final isAndroid = widget.isAndroid ?? false;

    return isFrontCamera && isAndroid;
  }

  Future<void> _processVideo() async {
    if (widget.videoPath == null) return;

    try {
      final editor = VideoEditorBuilder(videoPath: widget.videoPath!)
          .flip(flipDirection: FlipDirection.horizontal);

      // Export with progress tracking
      final outputPath = await editor.export(
        onProgress: (progress) {
          setState(() {
            _processingProgress = progress;
          });
        },
      );

      if (outputPath == null) {
        throw Exception('Failed to process video - output path is null');
      }

      _processedVideoPath = outputPath;
      await _initializeVideoPlayer();

      // Call the callback with the processed video path
      await widget.onVideoEdited?.call(outputPath);
    } catch (e) {
      throw Exception('Video processing failed: $e');
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

      // If no flipping was needed, still call the callback
      if (!_shouldAutoFlip) {
        await widget.onVideoEdited?.call(_processedVideoPath!);
      }
    } catch (e) {
      throw Exception('Video player initialization failed: $e');
    }
  }

  void _handleError(String error) {
    widget.onError?.call(error);
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
                      _shouldAutoFlip
                          ? 'Processing video...'
                          : 'Loading video...',
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            fontFamily: 'Readex Pro',
                            color: Colors.white,
                          ),
                    ),
                    if (_processingProgress > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: 200,
                        child: LinearProgressIndicator(
                          value: _processingProgress,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(_processingProgress * 100).toStringAsFixed(0)}%',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
