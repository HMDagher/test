import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'document_scanner_page_model.dart';
export 'document_scanner_page_model.dart';

class DocumentScannerPageWidget extends StatefulWidget {
  const DocumentScannerPageWidget({super.key});

  static String routeName = 'DocumentScannerPage';
  static String routePath = '/documentScannerPage';

  @override
  State<DocumentScannerPageWidget> createState() =>
      _DocumentScannerPageWidgetState();
}

class _DocumentScannerPageWidgetState extends State<DocumentScannerPageWidget> {
  late DocumentScannerPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DocumentScannerPageModel());
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
            child: custom_widgets.DocumentScannerWidget(
              width: double.infinity,
              height: double.infinity,
              onDocumentScanned: (imagePaths) async {},
              onScanningComplete: () async {},
            ),
          ),
        ),
      ),
    );
  }
}
