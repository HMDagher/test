import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'video_editor_page_model.dart';
export 'video_editor_page_model.dart';

class VideoEditorPageWidget extends StatefulWidget {
  const VideoEditorPageWidget({
    super.key,
    required this.videoPath,
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
        backgroundColor: FlutterFlowTheme.of(context).primaryText,
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: custom_widgets.VideoEditorWidget(
              width: double.infinity,
              height: double.infinity,
              videoPath: widget.videoPath,
              onVideoEditingComplete: (editedVideoPath) async {
                _model.compressedVideopath =
                    await actions.compressVideoForUploadAction(
                  editedVideoPath,
                );

                safeSetState(() {});
              },
              onCloseEditor: () async {
                context.safePop();
              },
            ),
          ),
        ),
      ),
    );
  }
}
