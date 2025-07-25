import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home_page_widget.dart' show HomePageWidget;
import 'package:flutter/material.dart';

class HomePageModel extends FlutterFlowModel<HomePageWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_fFVideo = false;
  FFUploadedFile uploadedLocalFile_fFVideo =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  bool isDataUploading_fFImage = false;
  FFUploadedFile uploadedLocalFile_fFImage =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
