import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/index.dart';
import 'package:flutter/material.dart';
import 'camera_custom_page_model.dart';
export 'camera_custom_page_model.dart';

class CameraCustomPageWidget extends StatefulWidget {
  const CameraCustomPageWidget({super.key});

  static String routeName = 'CameraCustomPage';
  static String routePath = '/cameraCustomPage';

  @override
  State<CameraCustomPageWidget> createState() => _CameraCustomPageWidgetState();
}

class _CameraCustomPageWidgetState extends State<CameraCustomPageWidget> {
  late CameraCustomPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CameraCustomPageModel());
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
            child: custom_widgets.CameraCustomWidget(
              width: double.infinity,
              height: double.infinity,
              showControls: true,
              allowVideoRecording: true,
              flashMode: 'auto',
              resolutionPreset: 'high',
              enableAudio: true,
              showZoomControls: true,
              showFlashControls: true,
              showCameraSwitchButton: true,
              borderRadius: 12.0,
              isAndroid: isAndroid,
              onImageCaptured: (imagePath, isFrontCamera) async {
                context.pushNamed(
                  PreviewWidget.routeName,
                  queryParameters: {
                    'filePath': serializeParam(
                      imagePath,
                      ParamType.String,
                    ),
                    'mediaType': serializeParam(
                      'image',
                      ParamType.String,
                    ),
                  }.withoutNulls,
                );
              },
              onVideoCaptured: (videoPath, isFrontCamera) async {
                context.pushNamed(
                  PreviewWidget.routeName,
                  queryParameters: {
                    'filePath': serializeParam(
                      videoPath,
                      ParamType.String,
                    ),
                    'mediaType': serializeParam(
                      'video',
                      ParamType.String,
                    ),
                  }.withoutNulls,
                );
              },
              onError: (error) async {},
            ),
          ),
        ),
      ),
    );
  }
}
