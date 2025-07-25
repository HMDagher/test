// Automatic FlutterFlow imports
import "package:utility_functions_library_8g4bud/backend/schema/structs/index.dart"
    as utility_functions_library_8g4bud_data_schema;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart'; // Imports other custom widgets

import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'dart:io';
import 'dart:typed_data';

class MediaEditorWidget extends StatefulWidget {
  const MediaEditorWidget({
    super.key,
    this.width,
    this.height,
    required this.imagePath,
    this.onImageEditingComplete,
    this.onImageEditingStarted,
    this.onCloseEditor,
    this.enableStickers = true,
    this.enableEmojis = true,
  });

  final double? width;
  final double? height;
  final String imagePath;
  final Future<dynamic> Function(String base64Image)? onImageEditingComplete;
  final Future<dynamic> Function()? onImageEditingStarted;
  final Future<dynamic> Function()? onCloseEditor;
  final bool enableStickers;
  final bool enableEmojis;

  @override
  State<MediaEditorWidget> createState() => _MediaEditorWidgetState();
}

class _MediaEditorWidgetState extends State<MediaEditorWidget> {
  final GlobalKey<ProImageEditorState> editorKey = GlobalKey();

  static const bool _useMaterialDesign = true;

  /// Opens the sticker/emoji editor.
  void _openStickerEditor(ProImageEditorState editor) async {
    if (!widget.enableStickers) return;

    Layer? layer = await editor.openPage(FrostedGlassStickerPage(
      configs: editor.configs,
      callbacks: editor.callbacks,
    ));

    if (layer == null || !mounted) return;

    if (layer.runtimeType != WidgetLayer) {
      layer.scale = editor.configs.emojiEditor.initScale;
    }

    editor.addLayer(layer);
  }

  /// Calculates the number of columns for the EmojiPicker.
  int _calculateEmojiColumns(BoxConstraints constraints) =>
      max(1, (_useMaterialDesign ? 6 : 10) / 400 * constraints.maxWidth - 1)
          .floor();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: LayoutBuilder(builder: (context, constraints) {
        return _buildEditor(constraints);
      }),
    );
  }

  Widget _buildEditor(BoxConstraints constraints) {
    if (widget.imagePath.isEmpty) {
      return _buildErrorWidget('No image path provided');
    }

    return ProImageEditor.file(
      File(widget.imagePath),
      key: editorKey,
      callbacks: _buildCallbacks(),
      configs: _buildConfigs(constraints),
    );
  }

  ProImageEditorCallbacks _buildCallbacks() {
    return ProImageEditorCallbacks(
      onImageEditingStarted: () async {
        if (widget.onImageEditingStarted != null) {
          await widget.onImageEditingStarted!();
        }
      },
      onImageEditingComplete: (Uint8List bytes) async {
        if (widget.onImageEditingComplete != null) {
          // Convert bytes to base64 string for FlutterFlow compatibility
          String base64Image = base64Encode(bytes);
          await widget.onImageEditingComplete!(base64Image);
        } else {
          if (mounted) {
            Navigator.pop(context);
          }
        }
      },
      onCloseEditor: (editorMode) async {
        if (widget.onCloseEditor != null) {
          await widget.onCloseEditor!();
        } else {
          if (mounted) {
            Navigator.pop(context);
          }
        }
      },
      stickerEditorCallbacks: StickerEditorCallbacks(
        onSearchChanged: (value) {
          debugPrint('Sticker search: $value');
        },
      ),
    );
  }

  ProImageEditorConfigs _buildConfigs(BoxConstraints constraints) {
    return ProImageEditorConfigs(
      designMode: ImageEditorDesignMode.material,
      theme: Theme.of(context).copyWith(
        iconTheme: Theme.of(context).iconTheme.copyWith(color: Colors.white),
      ),
      mainEditor: MainEditorConfigs(
        widgets: MainEditorWidgets(
          closeWarningDialog: (editor) async {
            if (!context.mounted) return false;
            return await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) =>
                      FrostedGlassCloseDialog(editor: editor),
                ) ??
                false;
          },
          appBar: (editor, rebuildStream) => null,
          bottomBar: (editor, rebuildStream, key) => null,
          bodyItems: _buildMainBodyWidgets,
        ),
      ),
      paintEditor: PaintEditorConfigs(
        icons: const PaintEditorIcons(
          bottomNavBar: Icons.edit,
        ),
        widgets: PaintEditorWidgets(
          appBar: (paintEditor, rebuildStream) => null,
          bottomBar: (paintEditor, rebuildStream) => null,
          colorPicker: (paintEditor, rebuildStream, currentColor, setColor) =>
              null,
          bodyItems: _buildPaintEditorBody,
        ),
        style: const PaintEditorStyle(
          initialStrokeWidth: 5,
        ),
      ),
      textEditor: TextEditorConfigs(
        customTextStyles: [
          GoogleFonts.roboto(),
          GoogleFonts.averiaLibre(),
          GoogleFonts.lato(),
          GoogleFonts.comicNeue(),
          GoogleFonts.actor(),
        ],
        style: TextEditorStyle(
          textFieldMargin: const EdgeInsets.only(top: kToolbarHeight),
          bottomBarBackground: Colors.transparent,
          bottomBarMainAxisAlignment: !_useMaterialDesign
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
        ),
        widgets: TextEditorWidgets(
          appBar: (textEditor, rebuildStream) => null,
          colorPicker: (textEditor, rebuildStream, currentColor, setColor) =>
              null,
          bottomBar: (textEditor, rebuildStream) => null,
          bodyItems: _buildTextEditorBody,
        ),
      ),
      cropRotateEditor: CropRotateEditorConfigs(
        widgets: CropRotateEditorWidgets(
          appBar: (cropRotateEditor, rebuildStream) => null,
          bottomBar: (cropRotateEditor, rebuildStream) => ReactiveWidget(
            stream: rebuildStream,
            builder: (_) => FrostedGlassCropRotateToolbar(
              configs: cropRotateEditor.configs,
              onCancel: cropRotateEditor.close,
              onRotate: cropRotateEditor.rotate,
              onDone: cropRotateEditor.done,
              onReset: cropRotateEditor.reset,
              openAspectRatios: cropRotateEditor.openAspectRatioOptions,
            ),
          ),
        ),
      ),
      filterEditor: FilterEditorConfigs(
        style: const FilterEditorStyle(
          filterListSpacing: 7,
          filterListMargin: EdgeInsets.fromLTRB(8, 15, 8, 10),
        ),
        widgets: FilterEditorWidgets(
          slider: (editorState, rebuildStream, value, onChanged, onChangeEnd) =>
              ReactiveWidget(
            stream: rebuildStream,
            builder: (_) => Slider(
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
              value: value,
              activeColor: Colors.blue.shade200,
            ),
          ),
          appBar: (filterEditor, rebuildStream) => null,
          bodyItems: (filterEditor, rebuildStream) => [
            ReactiveWidget(
              stream: rebuildStream,
              builder: (_) =>
                  FrostedGlassFilterAppbar(filterEditor: filterEditor),
            ),
          ],
        ),
      ),
      tuneEditor: TuneEditorConfigs(
        widgets: TuneEditorWidgets(
          appBar: (filterEditor, rebuildStream) => null,
          bottomBar: (filterEditor, rebuildStream) => null,
          bodyItems: _buildTuneEditorBody,
        ),
      ),
      blurEditor: BlurEditorConfigs(
        widgets: BlurEditorWidgets(
          slider: (editorState, rebuildStream, value, onChanged, onChangeEnd) =>
              ReactiveWidget(
            stream: rebuildStream,
            builder: (_) => Slider(
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
              value: value,
              max: editorState.configs.blurEditor.maxBlur,
              activeColor: Colors.blue.shade200,
            ),
          ),
          appBar: (blurEditor, rebuildStream) => null,
          bodyItems: (blurEditor, rebuildStream) => [
            ReactiveWidget(
              stream: rebuildStream,
              builder: (_) => FrostedGlassBlurAppbar(blurEditor: blurEditor),
            ),
          ],
        ),
      ),
      emojiEditor: EmojiEditorConfigs(
        enabled: widget.enableEmojis,
        checkPlatformCompatibility: !kIsWeb,
        style: EmojiEditorStyle(
          backgroundColor: Colors.transparent,
          textStyle: DefaultEmojiTextStyle.copyWith(
            fontFamily:
                !kIsWeb ? null : GoogleFonts.notoColorEmoji().fontFamily,
            fontSize: _useMaterialDesign ? 48 : 30,
          ),
          emojiViewConfig: EmojiViewConfig(
            gridPadding: EdgeInsets.zero,
            horizontalSpacing: 0,
            verticalSpacing: 0,
            recentsLimit: 40,
            backgroundColor: Colors.transparent,
            buttonMode: !_useMaterialDesign
                ? ButtonMode.CUPERTINO
                : ButtonMode.MATERIAL,
            loadingIndicator: const Center(child: CircularProgressIndicator()),
            columns: _calculateEmojiColumns(constraints),
            emojiSizeMax: !_useMaterialDesign ? 32 : 64,
            replaceEmojiOnLimitExceed: false,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
        ),
      ),
      stickerEditor: StickerEditorConfigs(
        enabled: widget.enableStickers,
      ),
      layerInteraction: const LayerInteractionConfigs(
        style: LayerInteractionStyle(
          removeAreaBackgroundInactive: Colors.black12,
        ),
      ),
      dialogConfigs: DialogConfigs(
        widgets: DialogWidgets(
          loadingDialog: (message, configs) => FrostedGlassLoadingDialog(
            message: message,
            configs: configs,
          ),
        ),
      ),
    );
  }

  List<ReactiveWidget> _buildMainBodyWidgets(
    ProImageEditorState editor,
    Stream<dynamic> rebuildStream,
  ) {
    return [
      if (editor.selectedLayerIndex < 0)
        ReactiveWidget(
          stream: rebuildStream,
          builder: (_) => FrostedGlassActionBar(
            editor: editor,
            openStickerEditor: () => _openStickerEditor(editor),
          ),
        ),
    ];
  }

  List<ReactiveWidget> _buildPaintEditorBody(
    PaintEditorState paintEditor,
    Stream<dynamic> rebuildStream,
  ) {
    return [
      ReactiveWidget(
        stream: rebuildStream,
        builder: (_) {
          return paintEditor.isActive
              ? const SizedBox.shrink()
              : FrostedGlassPaintAppbar(paintEditor: paintEditor);
        },
      ),
      ReactiveWidget(
        stream: rebuildStream,
        builder: (_) => FrostedGlassPaintBottomBar(paintEditor: paintEditor),
      ),
    ];
  }

  List<ReactiveWidget> _buildTuneEditorBody(
    TuneEditorState tuneEditor,
    Stream<dynamic> rebuildStream,
  ) {
    return [
      ReactiveWidget(
        stream: rebuildStream,
        builder: (_) => FrostedGlassTuneAppbar(tuneEditor: tuneEditor),
      ),
      ReactiveWidget(
        stream: rebuildStream,
        builder: (_) => FrostedGlassTuneBottombar(tuneEditor: tuneEditor),
      ),
    ];
  }

  List<ReactiveWidget> _buildTextEditorBody(
    TextEditorState textEditor,
    Stream<dynamic> rebuildStream,
  ) {
    return [
      ReactiveWidget(
        stream: rebuildStream,
        builder: (_) => const FrostedGlassEffect(
          radius: BorderRadius.zero,
          child: SizedBox.expand(),
        ),
      ),
      ReactiveWidget(
        stream: rebuildStream,
        builder: (_) => Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight),
          child: FrostedGlassTextSizeSlider(textEditor: textEditor),
        ),
      ),
      ReactiveWidget(
        stream: rebuildStream,
        builder: (_) => FrostedGlassTextAppbar(textEditor: textEditor),
      ),
      ReactiveWidget(
        stream: rebuildStream,
        builder: (_) => FrostedGlassTextBottomBar(
          configs: textEditor.configs,
          initColor: textEditor.primaryColor,
          onColorChanged: (color) {
            textEditor.primaryColor = color;
          },
          selectedStyle: textEditor.selectedTextStyle,
          onFontChange: textEditor.setTextStyle,
        ),
      ),
    ];
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
