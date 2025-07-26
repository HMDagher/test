import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'preview_model.dart';
export 'preview_model.dart';

class PreviewWidget extends StatefulWidget {
  const PreviewWidget({
    super.key,
    required this.filePath,
    required this.mediaType,
  });

  final String? filePath;
  final String? mediaType;

  static String routeName = 'Preview';
  static String routePath = '/preview';

  @override
  State<PreviewWidget> createState() => _PreviewWidgetState();
}

class _PreviewWidgetState extends State<PreviewWidget> {
  late PreviewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PreviewModel());
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
            child: custom_widgets.MediaPreviewIosWidget(
              width: double.infinity,
              height: double.infinity,
              filePath: widget.filePath!,
              mediaType: widget.mediaType!,
            ),
          ),
        ),
      ),
    );
  }
}
