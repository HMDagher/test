// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'dart:async';
import 'package:video_player/video_player.dart';

class MediaPreviewIosWidget extends StatefulWidget {
  const MediaPreviewIosWidget({
    super.key,
    this.width,
    this.height,
    required this.filePath,
    required this.mediaType, // Should be "image" or "video"
  });

  final double? width;
  final double? height;
  final String filePath;
  final String mediaType;

  @override
  State<MediaPreviewIosWidget> createState() => _MediaPreviewIosWidgetState();
}

class _MediaPreviewIosWidgetState extends State<MediaPreviewIosWidget> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void didUpdateWidget(MediaPreviewIosWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filePath != oldWidget.filePath ||
        widget.mediaType != oldWidget.mediaType) {
      _disposeVideoController();
      _isInitialized = false;
      _initializeMedia();
    }
  }

  Future<void> _initializeMedia() async {
    if (widget.mediaType == 'video') {
      await _initializeVideoPlayer();
    } else {
      // For images, simply mark as initialized
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      final controller = VideoPlayerController.file(File(widget.filePath));
      _videoController = controller;

      // Wait for initialization
      await controller.initialize();

      if (!mounted) return;

      // Enable looping and start playback
      await controller.setLooping(true);
      await controller.play();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _disposeVideoController() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildMediaContent(),
    );
  }

  Widget _buildMediaContent() {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.mediaType == 'image') {
      return Image.file(
        File(widget.filePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $error');
          return const Center(
            child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
          );
        },
      );
    } else if (widget.mediaType == 'video') {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return Center(
          child: AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    } else {
      return const Center(
        child: Text(
          'Unsupported media type',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}
