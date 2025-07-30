// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:confetti/confetti.dart' as confetti_package;
import 'dart:math';
import 'dart:async';

class ConfettiWidget extends StatefulWidget {
  const ConfettiWidget({
    super.key,
    this.width,
    this.height,
    this.shouldTrigger = false,
    this.particleCount = 20,
    this.colors,
    this.duration = 3,
    this.confettiStyle = 'explosive',
    this.particleShape = 'star',
    this.enableMultipleBlasts = false,
    this.customGravity = 0.1,
    this.customDrag = 0.1,
  });

  final double? width;
  final double? height;
  final bool shouldTrigger;
  final int particleCount;
  final List<Color>? colors;
  final int duration;
  final String confettiStyle; // 'explosive', 'fountain', 'directional'
  final String particleShape; // 'star', 'heart', 'diamond', 'circle'
  final bool enableMultipleBlasts;
  final double customGravity;
  final double customDrag;

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> {
  late List<confetti_package.ConfettiController> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.enableMultipleBlasts) {
      // Create multiple controllers for different blast positions
      _controllers = List.generate(
          3,
          (index) => confetti_package.ConfettiController(
                duration: Duration(seconds: widget.duration),
              ));
    } else {
      _controllers = [
        confetti_package.ConfettiController(
          duration: Duration(seconds: widget.duration),
        )
      ];
    }
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shouldTrigger && !oldWidget.shouldTrigger) {
      _triggerConfetti();
    }

    // Reinitialize controllers if settings changed
    if (widget.enableMultipleBlasts != oldWidget.enableMultipleBlasts) {
      _disposeControllers();
      _initializeControllers();
    }
  }

  void _triggerConfetti() {
    if (widget.enableMultipleBlasts) {
      // Trigger blasts with delays for a cascading effect
      for (int i = 0; i < _controllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
          if (mounted) _controllers[i].play();
        });
      }
    } else {
      _controllers[0].play();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (var controller in _controllers) {
      controller.dispose();
    }
  }

  // Get blast directionality based on style
  confetti_package.BlastDirectionality _getBlastDirectionality() {
    switch (widget.confettiStyle) {
      case 'fountain':
        return confetti_package.BlastDirectionality.directional;
      case 'directional':
        return confetti_package.BlastDirectionality.directional;
      case 'explosive':
      default:
        return confetti_package.BlastDirectionality.explosive;
    }
  }

  // Get blast direction for directional styles
  double _getBlastDirection() {
    switch (widget.confettiStyle) {
      case 'fountain':
        return -pi / 2; // Upward
      case 'directional':
        return -pi / 4; // Diagonal up-right
      default:
        return 0;
    }
  }

  // Get the appropriate particle shape
  Path _getParticleShape(Size size) {
    switch (widget.particleShape) {
      case 'heart':
        return _drawHeart(size);
      case 'diamond':
        return _drawDiamond(size);
      case 'star':
        return drawStar(size);
      case 'circle':
      default:
        return _drawCircle(size);
    }
  }

  // Custom particle shapes
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);

    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }

    path.close();
    return path;
  }

  Path _drawHeart(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, height / 4);
    path.cubicTo(width / 4, 0, 0, height / 4, width / 4, height / 2);
    path.cubicTo(
        width / 4, 3 * height / 4, width / 2, height, width / 2, height);
    path.cubicTo(width / 2, height, 3 * width / 4, 3 * height / 4,
        3 * width / 4, height / 2);
    path.cubicTo(width, height / 4, 3 * width / 4, 0, width / 2, height / 4);

    return path;
  }

  Path _drawDiamond(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(width / 2, 0);
    path.lineTo(width, height / 2);
    path.lineTo(width / 2, height);
    path.lineTo(0, height / 2);
    path.close();

    return path;
  }

  Path _drawCircle(Size size) {
    final path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final defaultColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.cyan,
    ];

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Multiple confetti widgets for enhanced effects
          if (widget.enableMultipleBlasts) ...[
            // Left blast
            Align(
              alignment: Alignment.centerLeft,
              child: confetti_package.ConfettiWidget(
                confettiController: _controllers[0],
                blastDirectionality: _getBlastDirectionality(),
                blastDirection: widget.confettiStyle == 'directional'
                    ? -pi / 6
                    : _getBlastDirection(),
                particleDrag: widget.customDrag,
                emissionFrequency: 0.01,
                numberOfParticles: widget.particleCount ~/ 3,
                gravity: widget.customGravity,
                shouldLoop: false,
                colors: widget.colors ?? defaultColors,
                createParticlePath: _getParticleShape,
              ),
            ),
            // Center blast
            Align(
              alignment: Alignment.center,
              child: confetti_package.ConfettiWidget(
                confettiController: _controllers[1],
                blastDirectionality: _getBlastDirectionality(),
                blastDirection: _getBlastDirection(),
                particleDrag: widget.customDrag,
                emissionFrequency: 0.01,
                numberOfParticles: widget.particleCount ~/ 3,
                gravity: widget.customGravity,
                shouldLoop: false,
                colors: widget.colors ?? defaultColors,
                createParticlePath: _getParticleShape,
              ),
            ),
            // Right blast
            Align(
              alignment: Alignment.centerRight,
              child: confetti_package.ConfettiWidget(
                confettiController: _controllers[2],
                blastDirectionality: _getBlastDirectionality(),
                blastDirection: widget.confettiStyle == 'directional'
                    ? pi / 6
                    : _getBlastDirection(),
                particleDrag: widget.customDrag,
                emissionFrequency: 0.01,
                numberOfParticles: widget.particleCount ~/ 3,
                gravity: widget.customGravity,
                shouldLoop: false,
                colors: widget.colors ?? defaultColors,
                createParticlePath: _getParticleShape,
              ),
            ),
          ] else ...[
            // Single confetti widget (your original behavior)
            Align(
              alignment: Alignment.center,
              child: confetti_package.ConfettiWidget(
                confettiController: _controllers[0],
                blastDirectionality: _getBlastDirectionality(),
                blastDirection: _getBlastDirection(),
                particleDrag: widget.customDrag,
                emissionFrequency: 0.01,
                numberOfParticles: widget.particleCount,
                gravity: widget.customGravity,
                shouldLoop: false,
                colors: widget.colors ?? defaultColors,
                createParticlePath: _getParticleShape,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
