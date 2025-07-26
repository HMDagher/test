import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'image_editor_page_model.dart';
export 'image_editor_page_model.dart';

class ImageEditorPageWidget extends StatefulWidget {
  const ImageEditorPageWidget({
    super.key,
    this.imagePath,
  });

  final String? imagePath;

  static String routeName = 'ImageEditorPage';
  static String routePath = '/imageEditorPage';

  @override
  State<ImageEditorPageWidget> createState() => _ImageEditorPageWidgetState();
}

class _ImageEditorPageWidgetState extends State<ImageEditorPageWidget> {
  late ImageEditorPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImageEditorPageModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: custom_widgets.ImageEditorWidget(
              width: double.infinity,
              height: double.infinity,
              imagePath: widget.imagePath,
              onImageEditingComplete: (imagePath) async {},
              onCloseEditor: () async {},
            ),
          ),
        ),
      ),
    );
  }
}
