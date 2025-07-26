import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'video_editor_page_model.dart';
export 'video_editor_page_model.dart';

class VideoEditorPageWidget extends StatefulWidget {
  const VideoEditorPageWidget({
    super.key,
    this.videoPath,
  });

  final String? videoPath;

  static String routeName = 'VideoEditorPage';
  static String routePath = '/videoEditorPage';

  @override
  State<VideoEditorPageWidget> createState() => _VideoEditorPageWidgetState();
}

class _VideoEditorPageWidgetState extends State<VideoEditorPageWidget> {
  late VideoEditorPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VideoEditorPageModel());
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
      ),
    );
  }
}
