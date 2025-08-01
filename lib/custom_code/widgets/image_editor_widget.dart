// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/designs/frosted_glass/frosted_glass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

// Custom Sticker Widget - This is the actual sticker that gets placed on the image
class CustomSticker extends StatelessWidget {
  final String imageUrl;

  const CustomSticker({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 100,
          height: 100,
          color: Colors.grey.withValues(alpha: 0.3),
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.white54,
            size: 40,
          ),
        );
      },
    );
  }
}

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
        // Save edited image to a permanent location
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName =
            'edited_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String finalPath = '${appDir.path}/$fileName';
        final File finalFile = File(finalPath);
        await finalFile.writeAsBytes(bytes);

        await widget.onImageEditingComplete!(finalPath);
      } catch (e) {
        debugPrint('Error processing edited image: $e');
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

  // Opens the sticker/emoji editor
  void _openStickerEditor(ProImageEditorState editor) async {
    Layer? layer = await editor.openPage(
      FrostedGlassStickerPage(
        configs: editor.configs,
        callbacks: editor.callbacks,
      ),
    );
    if (layer == null || !mounted) return;
    if (layer.runtimeType != WidgetLayer) {
      layer.scale = editor.configs.emojiEditor.initScale;
    }
    editor.addLayer(layer);
  }

  // Custom sticker builder
  Widget _buildCustomStickers(
    void Function(WidgetLayer widget) setLayer,
    ScrollController scrollController,
  ) {
    // Base URL for your sticker folder
    const String baseUrl = 'https://inoutapp.io/images/stickers/';

    // List of your sticker filenames (you need to know the filenames)
    final List<String> stickerFilenames = [
      'mascot-lebnene.png',
      'mascot-love.png',
      'mascot-bored.png',
      'mascot-kiss.png',
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        color: const Color(0x80000000), // Match frosted glass theme
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 80,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          controller: scrollController,
          itemCount: stickerFilenames.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final String stickerUrl = baseUrl + stickerFilenames[index];

            return GestureDetector(
              onTap: () async {
                // Show loading while precaching the image
                LoadingDialog.instance.show(
                  context,
                  configs: const ProImageEditorConfigs(),
                  theme: Theme.of(context),
                );

                // Precache the network image to ensure it's loaded
                await precacheImage(
                  NetworkImage(stickerUrl),
                  context,
                );

                LoadingDialog.instance.hide();

                // Add the sticker to the image as an overlay
                setLayer(
                  WidgetLayer(
                    widget: CustomSticker(imageUrl: stickerUrl),
                    exportConfigs: WidgetLayerExportConfigs(
                      networkUrl: stickerUrl, // Use network URL for export
                    ),
                  ),
                );
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.network(
                      stickerUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.withValues(alpha: 0.3),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              color: Colors.white54,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.withValues(alpha: 0.3),
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 30,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        clipBehavior: Clip.antiAlias,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No image provided',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select an image to start editing',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
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
        color: Colors.black, // Full black background
      ),
      clipBehavior: Clip.antiAlias,
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

          // Apply frosted glass theme
          theme: Theme.of(context).copyWith(
            iconTheme:
                Theme.of(context).iconTheme.copyWith(color: Colors.white),
          ),

          // Main editor with frosted glass theme and zoom enabled
          mainEditor: MainEditorConfigs(
            enableZoom:
                true, // Enable zoom for easier editing (doesn't affect final image)
            enableDoubleTapZoom: true, // Double-tap to zoom
            doubleTapZoomFactor: 2.0, // 2x zoom on double-tap
            editorMinScale: 1.0, // Minimum zoom level
            editorMaxScale: 5.0, // Maximum zoom level (5x)
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
              bodyItems: (editor, rebuildStream) => [
                if (editor.selectedLayerIndex < 0)
                  ReactiveWidget(
                    stream: rebuildStream,
                    builder: (_) => FrostedGlassActionBar(
                      editor: editor,
                      openStickerEditor: () => _openStickerEditor(editor),
                    ),
                  ),
              ],
            ),
          ),

          // Text editor with Google Fonts and frosted glass design
          textEditor: TextEditorConfigs(
            enabled: true,
            customTextStyles: [
              GoogleFonts.roboto(),
              GoogleFonts.averiaLibre(),
              GoogleFonts.lato(),
              GoogleFonts.comicNeue(),
              GoogleFonts.actor(),
              GoogleFonts.odorMeanChey(),
              GoogleFonts.nabla(),
              GoogleFonts.poppins(),
              GoogleFonts.openSans(),
              GoogleFonts.montserrat(),
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
              colorPicker:
                  (textEditor, rebuildStream, currentColor, setColor) => null,
              bottomBar: (textEditor, rebuildStream) => null,
              bodyItems: (textEditor, rebuildStream) => [
                // Background
                ReactiveWidget(
                  stream: rebuildStream,
                  builder: (_) => const FrostedGlassEffect(
                    radius: BorderRadius.zero,
                    child: SizedBox.expand(),
                  ),
                ),
                // Text size slider
                ReactiveWidget(
                  stream: rebuildStream,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.only(top: kToolbarHeight),
                    child: FrostedGlassTextSizeSlider(textEditor: textEditor),
                  ),
                ),
                // App bar
                ReactiveWidget(
                  stream: rebuildStream,
                  builder: (_) =>
                      FrostedGlassTextAppbar(textEditor: textEditor),
                ),
                // Bottom bar
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
              ],
            ),
          ),

          // Filter editor with frosted glass design
          filterEditor: FilterEditorConfigs(
            enabled: true,
            style: const FilterEditorStyle(
              filterListSpacing: 7,
              filterListMargin: EdgeInsets.fromLTRB(8, 15, 8, 10),
            ),
            widgets: FilterEditorWidgets(
              slider:
                  (editorState, rebuildStream, value, onChanged, onChangeEnd) =>
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

          // Emoji editor with frosted glass design
          emojiEditor: EmojiEditorConfigs(
            enabled: true,
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
                loadingIndicator:
                    const Center(child: CircularProgressIndicator()),
                columns: _calculateEmojiColumns(BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height,
                )),
                emojiSizeMax: !_useMaterialDesign ? 32 : 64,
                replaceEmojiOnLimitExceed: false,
              ),
              bottomActionBarConfig:
                  const BottomActionBarConfig(enabled: false),
            ),
          ),

          // Sticker editor with custom builder
          stickerEditor: StickerEditorConfigs(
            enabled: true,
            builder: _buildCustomStickers,
          ),

          // Layer interaction with frosted glass style
          layerInteraction: const LayerInteractionConfigs(
            style: LayerInteractionStyle(
              removeAreaBackgroundInactive: Colors.black12,
            ),
          ),

          // Dialog configs with frosted glass loading dialog
          dialogConfigs: DialogConfigs(
            widgets: DialogWidgets(
              loadingDialog: (message, configs) => FrostedGlassLoadingDialog(
                message: message,
                configs: configs,
              ),
            ),
          ),

          // DISABLED EDITORS
          tuneEditor: const TuneEditorConfigs(enabled: false),
          blurEditor: const BlurEditorConfigs(enabled: false),
          paintEditor: const PaintEditorConfigs(enabled: false),
          cropRotateEditor: const CropRotateEditorConfigs(enabled: false),
        ),
      ),
    );
  }
}
