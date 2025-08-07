// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';

class DocumentScannerWidget extends StatefulWidget {
  const DocumentScannerWidget({
    super.key,
    this.width,
    this.height,
    this.onDocumentScanned,
  });

  final double? width;
  final double? height;
  final Future<dynamic> Function(String imagePath)? onDocumentScanned;

  @override
  State<DocumentScannerWidget> createState() => _DocumentScannerWidgetState();
}

class _DocumentScannerWidgetState extends State<DocumentScannerWidget> {
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    // Open scanner immediately when widget loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scanDocument();
    });
  }

  Future<void> scanDocument() async {
    setState(() {
      isScanning = true;
    });

    try {
      // Use getScanDocuments to get the camera scanner directly
      dynamic result = await FlutterDocScanner().getScanDocuments();

      if (result != null) {
        String imagePath;
        if (result is List && result.isNotEmpty) {
          // Take the first scanned image
          imagePath = result.first.toString();
        } else {
          imagePath = result.toString();
        }

        // Call the callback with the single image path
        if (widget.onDocumentScanned != null) {
          await widget.onDocumentScanned!(imagePath);
        }
      }
    } on PlatformException catch (e) {
      print('Failed to scan document: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to scan document: ${e.message}')),
        );
      }
    } catch (e) {
      print('Error scanning document: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning document')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Center(
        child: isScanning
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Opening Scanner...',
                    style: FlutterFlowTheme.of(context).bodyLarge,
                  ),
                ],
              )
            : ElevatedButton.icon(
                onPressed: scanDocument,
                icon: Icon(Icons.document_scanner),
                label: Text('Scan Receipt'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
      ),
    );
  }
}
