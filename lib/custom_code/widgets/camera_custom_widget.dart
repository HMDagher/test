// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// Data class to hold captured media information
class CapturedMediaInfo {
  final String filePath;
  final bool isFrontCamera;
  final String mediaType; // 'image' or 'video'
  final DateTime capturedAt;

  CapturedMediaInfo({
    required this.filePath,
    required this.isFrontCamera,
    required this.mediaType,
    required this.capturedAt,
  });
}

// Helper functions to convert string parameters to camera package enums
FlashMode _convertFlashMode(String mode) {
  switch (mode.toLowerCase()) {
    case 'off':
      return FlashMode.off;
    case 'auto':
      return FlashMode.auto;
    case 'always':
    case 'on':
      return FlashMode.always;
    case 'torch':
      return FlashMode.torch;
    default:
      return FlashMode.auto;
  }
}

ResolutionPreset _convertResolution(String resolution) {
  switch (resolution.toLowerCase()) {
    case 'low':
      return ResolutionPreset.low;
    case 'medium':
      return ResolutionPreset.medium;
    case 'high':
      return ResolutionPreset.high;
    case 'veryhigh':
    case 'very_high':
      return ResolutionPreset.veryHigh;
    case 'ultrahigh':
    case 'ultra_high':
      return ResolutionPreset.ultraHigh;
    case 'max':
      return ResolutionPreset.max;
    default:
      return ResolutionPreset.high;
  }
}

class CameraCustomWidget extends StatefulWidget {
  const CameraCustomWidget({
    super.key,
    this.width,
    this.height,
    this.onImageCaptured,
    this.onVideoCaptured,
    this.onError,
    this.showControls = true,
    this.allowVideoRecording = true,
    this.flashMode = 'auto',
    this.resolutionPreset = 'high',
    this.enableAudio = true,
    this.showZoomControls = true,
    this.showFlashControls = true,
    this.showCameraSwitchButton = true,
    this.borderRadius = 12.0,
    this.isAndroid = true,
  });

  final double? width;
  final double? height;
  final Future<dynamic> Function(String imagePath, bool isFrontCamera)?
      onImageCaptured;
  final Future<dynamic> Function(String videoPath, bool isFrontCamera)?
      onVideoCaptured;
  final Future<dynamic> Function(String error)? onError;
  final bool showControls;
  final bool allowVideoRecording;
  final String flashMode;
  final String resolutionPreset;
  final bool enableAudio;
  final bool showZoomControls;
  final bool showFlashControls;
  final bool showCameraSwitchButton;
  final double borderRadius;
  final bool isAndroid;

  @override
  State<CameraCustomWidget> createState() => _CameraCustomWidgetState();
}

class _CameraCustomWidgetState extends State<CameraCustomWidget>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isRecording = false;
  VideoPlayerController? _videoController;

  // Recording timer and progress
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  static const int _maxRecordingSeconds = 30;

  // Camera settings
  FlashMode _currentFlashMode = FlashMode.auto;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseScale = 1.0;
  int _pointers = 0;

  // Camera lens management
  List<CameraDescription> _backCameras = [];
  List<CameraDescription> _frontCameras = [];
  int _currentBackCameraIndex = 0;
  int _currentFrontCameraIndex = 0;
  bool _isUsingFrontCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentFlashMode = _convertFlashMode(widget.flashMode);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    _controller?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCameraController(_cameras[_selectedCameraIndex]);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Separate cameras by lens direction
        _backCameras = _cameras
            .where((camera) => camera.lensDirection == CameraLensDirection.back)
            .toList();
        _frontCameras = _cameras
            .where(
                (camera) => camera.lensDirection == CameraLensDirection.front)
            .toList();

        // Start with back camera if available, otherwise front
        if (_backCameras.isNotEmpty) {
          _isUsingFrontCamera = false;
          _selectedCameraIndex = _cameras.indexOf(_backCameras[0]);
        } else if (_frontCameras.isNotEmpty) {
          _isUsingFrontCamera = true;
          _selectedCameraIndex = _cameras.indexOf(_frontCameras[0]);
        }

        await _initializeCameraController(_cameras[_selectedCameraIndex]);
      } else {
        _handleError('No cameras found on this device');
      }
    } catch (e) {
      _handleError('Failed to initialize camera: $e');
    }
  }

  Future<void> _initializeCameraController(CameraDescription camera) async {
    final CameraController cameraController = CameraController(
      camera,
      kIsWeb
          ? ResolutionPreset.max
          : _convertResolution(widget.resolutionPreset),
      enableAudio: widget.enableAudio && widget.allowVideoRecording,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = cameraController;

    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        _handleError(
            'Camera error: ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await cameraController.setFlashMode(_currentFlashMode);

      // Get zoom levels
      _maxZoom = await cameraController.getMaxZoomLevel();
      _minZoom = await cameraController.getMinZoomLevel();
      _currentZoom = _minZoom;

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      _handleError('Failed to initialize camera controller: $e');
    }
  }

  void _handleError(String error) {
    debugPrint('Camera Error: $error');
    widget.onError?.call(error);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Readex Pro',
                  color: FlutterFlowTheme.of(context).info,
                ),
          ),
          backgroundColor: FlutterFlowTheme.of(context).error,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: FlutterFlowTheme.of(context).info,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
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

  Future<void> _takePicture() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      _handleError('Camera not initialized');
      return;
    }

    if (cameraController.value.isTakingPicture) {
      return;
    }

    try {
      final XFile image = await cameraController.takePicture();
      Uint8List finalImageBytes = await image.readAsBytes();

      // Flip front camera images for both iOS and Android
      // This ensures the captured image matches what users see in the preview
      if (_isUsingFrontCamera) {
        try {
          finalImageBytes = await _flipImageHorizontally(finalImageBytes);
        } catch (e) {
          debugPrint('Failed to flip image, using original: $e');
          // If flipping fails, use the original bytes
        }
      }

      // Save processed image to a permanent location
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          'captured_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String finalPath = '${appDir.path}/$fileName';
      final File finalFile = File(finalPath);
      await finalFile.writeAsBytes(finalImageBytes);

      // Clean up the temporary file
      try {
        await File(image.path).delete();
      } catch (e) {
        debugPrint('Failed to delete temporary file: $e');
      }

      // Pass the image path and camera info to the callback
      await widget.onImageCaptured?.call(finalPath, _isUsingFrontCamera);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Photo captured!',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).info,
                  ),
            ),
            backgroundColor: FlutterFlowTheme.of(context).success,
          ),
        );
      }
    } catch (e) {
      _handleError('Failed to take picture: $e');
    }
  }

  Future<void> _startVideoRecording() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      _handleError('Camera not initialized');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      await cameraController.startVideoRecording();
      if (mounted) {
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });
        _startRecordingTimer();
      }
    } catch (e) {
      _handleError('Failed to start video recording: $e');
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isRecording) {
        setState(() {
          _recordingSeconds++;
        });

        // Auto-stop recording at 30 seconds
        if (_recordingSeconds >= _maxRecordingSeconds) {
          _stopVideoRecording();
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _stopVideoRecording() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return;
    }

    try {
      final XFile video = await cameraController.stopVideoRecording();
      final Uint8List videoBytes = await video.readAsBytes();

      // Save video to a permanent location
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName =
          'captured_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String finalPath = '${appDir.path}/$fileName';
      final File finalFile = File(finalPath);
      await finalFile.writeAsBytes(videoBytes);

      // Clean up the temporary file
      try {
        await File(video.path).delete();
      } catch (e) {
        debugPrint('Failed to delete temporary video file: $e');
      }

      // Pass both the video path and camera info to the callback
      await widget.onVideoCaptured?.call(finalPath, _isUsingFrontCamera);

      _recordingTimer?.cancel();

      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordingSeconds = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Video recorded!',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).info,
                  ),
            ),
            backgroundColor: FlutterFlowTheme.of(context).success,
          ),
        );
      }
    } catch (e) {
      _handleError('Failed to stop video recording: $e');
    }
  }

  Future<void> _switchCamera() async {
    // Switch between front and back cameras only
    if (_isUsingFrontCamera && _backCameras.isNotEmpty) {
      // Switch to back camera
      _isUsingFrontCamera = false;
      _selectedCameraIndex =
          _cameras.indexOf(_backCameras[_currentBackCameraIndex]);
    } else if (!_isUsingFrontCamera && _frontCameras.isNotEmpty) {
      // Switch to front camera
      _isUsingFrontCamera = true;
      _selectedCameraIndex =
          _cameras.indexOf(_frontCameras[_currentFrontCameraIndex]);
    }

    await _initializeCameraController(_cameras[_selectedCameraIndex]);
  }

  IconData _getCameraIcon() {
    // Always use the refresh/sync icon for camera switching
    return Icons.sync;
  }

  Future<void> _toggleFlashMode() async {
    final CameraController? cameraController = _controller;
    if (cameraController == null) return;

    FlashMode newMode;

    if (_isUsingFrontCamera) {
      // Front cameras: only toggle between off and auto (no always/torch)
      switch (_currentFlashMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
        case FlashMode.always:
        case FlashMode.torch:
          newMode = FlashMode.off;
          break;
      }
    } else {
      // Back cameras: full flash mode cycle
      switch (_currentFlashMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        case FlashMode.always:
          newMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          newMode = FlashMode.off;
          break;
      }
    }

    try {
      await cameraController.setFlashMode(newMode);
      setState(() {
        _currentFlashMode = newMode;
      });
    } catch (e) {
      // Handle flash mode errors gracefully
      if (e.toString().contains('torch mode') ||
          e.toString().contains('flash')) {
        // For front cameras, just switch to off mode
        if (_isUsingFrontCamera) {
          try {
            await cameraController.setFlashMode(FlashMode.off);
            setState(() {
              _currentFlashMode = FlashMode.off;
            });
          } catch (_) {}
        }
      } else {
        _handleError('Failed to set flash mode: $e');
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentZoom;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    final CameraController? cameraController = _controller;
    if (cameraController == null || _pointers != 2) {
      return;
    }

    _currentZoom = (_baseScale * details.scale).clamp(_minZoom, _maxZoom);
    await cameraController.setZoomLevel(_currentZoom);
  }

  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final CameraController? cameraController = _controller;
    if (cameraController == null) return;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _controller == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.previewSize?.height ?? 1,
          height: _controller!.value.previewSize?.width ?? 1,
          child: Listener(
            onPointerDown: (_) => _pointers++,
            onPointerUp: (_) => _pointers--,
            child: CameraPreview(
              _controller!,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate,
                    onTapDown: (details) =>
                        _onViewFinderTap(details, constraints),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    if (!widget.showControls) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoom lens switcher for back cameras
                  if (!_isUsingFrontCamera && _backCameras.length > 1)
                    _buildZoomLensSwitcher(),

                  const SizedBox(height: 16),

                  // Main controls row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Flash control (left side)
                      if (widget.showFlashControls)
                        _buildSideControlButton(
                          icon: _getFlashIcon(),
                          onPressed: _toggleFlashMode,
                        )
                      else
                        const SizedBox(width: 44),

                      // Main capture button (center)
                      _buildInstagramStyleCaptureButton(),

                      // Camera switch (right side)
                      if ((_backCameras.isNotEmpty &&
                              _frontCameras.isNotEmpty) &&
                          widget.showCameraSwitchButton)
                        _buildSideControlButton(
                          icon: _getCameraIcon(),
                          onPressed: _switchCamera,
                        )
                      else
                        const SizedBox(width: 44),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSideControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 44,
          height: 44,
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
            icon: Icon(
              icon,
              color: color ?? Colors.white,
              size: 20,
            ),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomLensSwitcher() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _backCameras.asMap().entries.map((entry) {
              final index = entry.key;
              final camera = entry.value;
              final isSelected = index == _currentBackCameraIndex;

              // Generate zoom labels (1x, 2x, 3x, etc.)
              final zoomLabel = '${index + 1}x';

              return GestureDetector(
                onTap: () async {
                  if (index != _currentBackCameraIndex) {
                    _currentBackCameraIndex = index;
                    _selectedCameraIndex = _cameras.indexOf(camera);
                    await _initializeCameraController(camera);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    zoomLabel,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.8),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInstagramStyleCaptureButton() {
    return GestureDetector(
      onTap: _takePicture,
      onLongPressStart: (_) {
        if (widget.allowVideoRecording) {
          _startVideoRecording();
        }
      },
      onLongPressEnd: (_) {
        if (_isRecording) {
          _stopVideoRecording();
        }
      },
      child: Container(
        width: 72,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring with frosted glass effect
            ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Progress indicator (only visible when recording)
            if (_isRecording)
              SizedBox(
                width: 68,
                height: 68,
                child: CircularProgressIndicator(
                  value: _recordingSeconds / _maxRecordingSeconds,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),

            // Main button
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _isRecording
                    ? FlutterFlowTheme.of(context).error
                    : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFlashIcon() {
    switch (_currentFlashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
    }
  }

  Widget _buildRecordingIndicator() {
    if (!_isRecording) return const SizedBox.shrink();

    final minutes = _recordingSeconds ~/ 60;
    final seconds = _recordingSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Positioned(
      top: 50,
      left: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).error.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'REC $timeString',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Readex Pro',
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomIndicator() {
    if (_currentZoom <= _minZoom) return const SizedBox.shrink();

    return Positioned(
      top: 50,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${_currentZoom.toStringAsFixed(1)}x',
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Readex Pro',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black, // Full black background
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),
          _buildControls(),
          _buildRecordingIndicator(),
          _buildZoomIndicator(),
        ],
      ),
    );
  }
}
