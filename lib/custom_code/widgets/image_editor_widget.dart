// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class ImageEditorWidget extends StatefulWidget {
  const ImageEditorWidget({
    super.key,
    this.width,
    this.height,
    this.imagePath,
    this.onImageEditingComplete,
    this.onCloseEditor,
  });

  final double? width;
  final double? height;
  final String? imagePath;
  final Future<dynamic> Function(String imagePath)? onImageEditingComplete;
  final Future<dynamic> Function()? onCloseEditor;

  @override
  State<ImageEditorWidget> createState() => _ImageEditorWidgetState();
}

class _ImageEditorWidgetState extends State<ImageEditorWidget> {
  final GlobalKey<ProImageEditorState> editorKey =
      GlobalKey<ProImageEditorState>();
  final bool _useMaterialDesign = true;

  void onImageEditingStarted() {
    // Handle editing started
  }

  Future<void> onImageEditingComplete(Uint8List bytes) async {
    if (widget.onImageEditingComplete != null) {
      try {
        final Directory tempDir = Directory.systemTemp;
        final String fileName =
            'edited_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final File tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(bytes);

        await widget.onImageEditingComplete!(tempFile.path);
      } catch (e) {
        debugPrint('Error saving edited image: $e');
      }
    }
  }

  void onCloseEditor(EditorMode editorMode) async {
    if (widget.onCloseEditor != null) {
      await widget.onCloseEditor!();
    }
  }

  void vibrateLineHit() {
    // Add haptic feedback if needed
  }

  int _calculateEmojiColumns(BoxConstraints constraints) =>
      max(1, (_useMaterialDesign ? 6 : 10) / 400 * constraints.maxWidth - 1)
          .floor();

  @override
  Widget build(BuildContext context) {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: const Center(
          child: Text('No image provided'),
        ),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      child: ProImageEditor.file(
        File(widget.imagePath!),
        key: editorKey,
        callbacks: ProImageEditorCallbacks(
          onImageEditingStarted: onImageEditingStarted,
          onImageEditingComplete: onImageEditingComplete,
          onCloseEditor: onCloseEditor,
          mainEditorCallbacks: MainEditorCallbacks(
            helperLines: HelperLinesCallbacks(
              onLineHit: vibrateLineHit,
            ),
          ),
        ),
        configs: ProImageEditorConfigs(
          designMode: _useMaterialDesign
              ? ImageEditorDesignMode.material
              : ImageEditorDesignMode.cupertino,

          // Main editor with glassy theme
          mainEditor: const MainEditorConfigs(
            style: MainEditorStyle(
              background: Color(0xFF000000),
              bottomBarBackground: Color(0x80000000), // Semi-transparent black
            ),
            icons: MainEditorIcons(
              closeEditor: Icons.close,
              doneIcon: Icons.check,
              undoAction: Icons.undo,
              redoAction: Icons.redo,
            ),
          ),

          // Paint editor - ENABLED
          paintEditor: const PaintEditorConfigs(
            enabled: true,
            style: PaintEditorStyle(
              background: Color(0xFF000000),
              bottomBarBackground: Color(0x99000000), // More transparent
              initialStrokeWidth: 5.0,
              initialColor: Colors.white,
            ),
            icons: PaintEditorIcons(
              bottomNavBar: Icons.brush,
              lineWeight: Icons.line_weight,
              freeStyle: Icons.gesture,
              arrow: Icons.arrow_forward,
              line: Icons.horizontal_rule,
              rectangle: Icons.crop_free,
              circle: Icons.circle_outlined,
            ),
          ),

          // Text editor - ENABLED
          textEditor: TextEditorConfigs(
            enabled: true,
            style: const TextEditorStyle(
              background: Color(0xFF000000),
              bottomBarBackground: Color(0x99000000), // More transparent
            ),
            icons: const TextEditorIcons(
              bottomNavBar: Icons.text_fields,
              alignLeft: Icons.format_align_left,
              alignCenter: Icons.format_align_center,
              alignRight: Icons.format_align_right,
              backgroundMode: Icons.layers,
            ),
          ),

          // Crop/Rotate editor - ENABLED
          cropRotateEditor: const CropRotateEditorConfigs(
            enabled: true,
            style: CropRotateEditorStyle(
              background: Color(0xFF000000),
              bottomBarBackground: Color(0x99000000), // More transparent
              cropCornerColor: Colors.white,
              helperLineColor: Colors.white54,
            ),
            icons: CropRotateEditorIcons(
              bottomNavBar: Icons.crop,
              rotate: Icons.rotate_left,
              aspectRatio: Icons.aspect_ratio,
            ),
          ),

          // Filter editor - ENABLED
          filterEditor: FilterEditorConfigs(
            enabled: true,
            style: const FilterEditorStyle(
              background: Color(0x99000000), // More transparent
              filterListMargin: EdgeInsets.all(8),
            ),
            icons: const FilterEditorIcons(
              bottomNavBar: Icons.filter,
            ),
          ),

          // Emoji editor - ENABLED
          emojiEditor: EmojiEditorConfigs(
            enabled: true,
            checkPlatformCompatibility: !kIsWeb,
            style: EmojiEditorStyle(
              backgroundColor: const Color(0x99000000), // More transparent
              textStyle: DefaultEmojiTextStyle.copyWith(
                fontSize: _useMaterialDesign ? 48 : 30,
              ),
              emojiViewConfig: EmojiViewConfig(
                columns: _calculateEmojiColumns(BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height,
                )),
                backgroundColor: const Color(0x99000000), // More transparent
                buttonMode: _useMaterialDesign
                    ? ButtonMode.MATERIAL
                    : ButtonMode.CUPERTINO,
              ),
            ),
            icons: const EmojiEditorIcons(
              bottomNavBar: Icons.emoji_emotions,
            ),
          ),

          // DISABLED EDITORS
          tuneEditor: const TuneEditorConfigs(enabled: false),
          blurEditor: const BlurEditorConfigs(enabled: false),
          stickerEditor: const StickerEditorConfigs(enabled: false),

          // Theme
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
        ),
      ),
    );
  }
}
