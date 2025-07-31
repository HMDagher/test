// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:tiktoklikescroller/tiktoklikescroller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

class ReelScrollerWidget extends StatefulWidget {
  const ReelScrollerWidget({
    super.key,
    this.width,
    this.height,
    this.reelDataStruct,
    this.onPageChanged,
    this.onLikeTap,
    this.onUserAvatarTap,
    this.onPlaceAvatarTap,
    this.onReportTap,
    this.onViewAction,
    this.currentIndex = 0,
  });

  final double? width;
  final double? height;
  final List<ReelStruct>? reelDataStruct;
  final Future<dynamic> Function(int currentReelIndex)? onPageChanged;
  final Future<dynamic> Function(int reelIndex)? onLikeTap;
  final Future<dynamic> Function(int reelIndex)? onUserAvatarTap;
  final Future<dynamic> Function(int reelIndex)? onPlaceAvatarTap;
  final Future<dynamic> Function(int reelIndex)? onReportTap;
  final Future<dynamic> Function(int reelIndex)? onViewAction;
  final int currentIndex;

  @override
  State<ReelScrollerWidget> createState() => _ReelScrollerWidgetState();
}

class _ReelScrollerWidgetState extends State<ReelScrollerWidget> {
  late Controller controller;
  int currentPageIndex = 0;
  Map<int, VideoPlayerController> videoControllers = {};

  // Sample data for demonstration - will be replaced by FlutterFlow data
  final List<ReelStruct> sampleReelData = [];

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.currentIndex;
    controller = Controller()
      ..addListener((event) {
        _handleScrollEvent(event.direction, event.success);
      });

    // Trigger view action for initial reel after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerViewAction();
    });
  }

  @override
  void dispose() {
    // Dispose video controllers
    for (var videoController in videoControllers.values) {
      videoController.dispose();
    }
    // Note: Controller from tiktoklikescroller doesn't have dispose method
    super.dispose();
  }

  void _handleScrollEvent(ScrollDirection direction, ScrollSuccess success) {
    if (success == ScrollSuccess.SUCCESS) {
      setState(() {
        if (direction == ScrollDirection.FORWARD) {
          currentPageIndex++;
        } else if (direction == ScrollDirection.BACKWARDS) {
          currentPageIndex--;
        }
      });

      // Pause previous video and play current if it's a video
      _handleVideoPlayback();

      // Auto-trigger view action for the current reel
      _triggerViewAction();

      // Notify FlutterFlow about page change
      if (widget.onPageChanged != null) {
        widget.onPageChanged!(currentPageIndex);
      }
    }
  }

  void _triggerViewAction() async {
    final reelData = widget.reelDataStruct ?? sampleReelData;
    if (currentPageIndex < reelData.length && widget.onViewAction != null) {
      try {
        await widget.onViewAction!(currentPageIndex);
      } catch (e) {
        debugPrint('Error triggering view action: $e');
      }
    }
  }

  void _handleVideoPlayback() {
    final reelData = widget.reelDataStruct ?? sampleReelData;

    // Pause all videos first
    for (var controller in videoControllers.values) {
      controller.pause();
    }

    // Play current video if it exists and is a video
    if (currentPageIndex < reelData.length &&
        reelData[currentPageIndex].isVideo) {
      final videoController = videoControllers[currentPageIndex];
      if (videoController != null && videoController.value.isInitialized) {
        videoController.play();
      }
    }
  }

  Widget _buildMediaWidget(ReelStruct reelData, int index) {
    if (reelData.isVideo) {
      // Initialize video controller if not exists
      if (!videoControllers.containsKey(index)) {
        videoControllers[index] =
            VideoPlayerController.network(reelData.mediaUrl)
              ..initialize().then((_) {
                if (mounted && index == currentPageIndex) {
                  setState(() {});
                  videoControllers[index]!.play();
                }
              });
      }

      final videoController = videoControllers[index]!;
      return videoController.value.isInitialized
          ? AspectRatio(
              aspectRatio: videoController.value.aspectRatio,
              child: VideoPlayer(videoController),
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
    } else {
      // Image
      return CachedNetworkImage(
        imageUrl: reelData.mediaUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: Icon(Icons.error, color: Colors.white, size: 50),
          ),
        ),
      );
    }
  }

  Widget _buildOverlayUI(ReelStruct reelData, int index) {
    return Stack(
      children: [
        // Right side actions
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              // Like button
              GestureDetector(
                onTap: () async {
                  if (widget.onLikeTap != null) {
                    await widget.onLikeTap!(index);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    reelData.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: reelData.isLiked ? Colors.red : Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${reelData.likesCount}',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),
              // Report button
              GestureDetector(
                onTap: () async {
                  if (widget.onReportTap != null) {
                    await widget.onReportTap!(index);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flag_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom left user and place info
        Positioned(
          left: 16,
          bottom: 100,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              GestureDetector(
                onTap: () async {
                  if (widget.onUserAvatarTap != null) {
                    await widget.onUserAvatarTap!(index);
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: reelData.userAvatarUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[600],
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 20),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[600],
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '@${reelData.userName}',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Place info
              GestureDetector(
                onTap: () async {
                  if (widget.onPlaceAvatarTap != null) {
                    await widget.onPlaceAvatarTap!(index);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: reelData.placeAvatarUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[600],
                              child: const Icon(Icons.place,
                                  color: Colors.white, size: 16),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[600],
                              child: const Icon(Icons.place,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reelData.placeName,
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            reelData.placeCategory,
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Inter',
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reelData = widget.reelDataStruct ?? sampleReelData;

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: TikTokStyleFullPageScroller(
        contentSize: reelData.length,
        swipePositionThreshold: 0.2,
        swipeVelocityThreshold: 2000,
        animationDuration: const Duration(milliseconds: 400),
        controller: controller,
        builder: (BuildContext context, int index) {
          final reel = reelData[index];

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                // Media content (image or video)
                _buildMediaWidget(reel, index),

                // Overlay UI (user info, place info, actions)
                _buildOverlayUI(reel, index),
              ],
            ),
          );
        },
      ),
    );
  }
}
