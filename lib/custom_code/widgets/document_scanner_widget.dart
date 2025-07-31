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
    this.onScanningComplete,
  });

  final double? width;
  final double? height;
  final Future<dynamic> Function(List<String> imagePaths)? onDocumentScanned;
  final Future<dynamic> Function()? onScanningComplete;

  @override
  State<DocumentScannerWidget> createState() => _DocumentScannerWidgetState();
}

class _DocumentScannerWidgetState extends State<DocumentScannerWidget> {
  List<String> scannedDocuments = [];
  bool isScanning = false;

  Future<void> scanDocuments() async {
    setState(() {
      isScanning = true;
    });

    try {
      // Scan documents as images with no page limit
      dynamic result = await FlutterDocScanner().getScanDocuments();

      if (result != null) {
        setState(() {
          if (result is List) {
            scannedDocuments = result.cast<String>();
          } else {
            scannedDocuments = [result.toString()];
          }
        });

        // Call the callback if provided
        if (widget.onDocumentScanned != null) {
          await widget.onDocumentScanned!(scannedDocuments);
        }
      }
    } on PlatformException catch (e) {
      print('Failed to scan documents: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan documents: ${e.message}')),
      );
    } catch (e) {
      print('Error scanning documents: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning documents')),
      );
    } finally {
      setState(() {
        isScanning = false;
      });

      // Call completion callback if provided
      if (widget.onScanningComplete != null) {
        await widget.onScanningComplete!();
      }
    }
  }

  void clearScannedDocuments() {
    setState(() {
      scannedDocuments.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scan Button
          ElevatedButton.icon(
            onPressed: isScanning ? null : scanDocuments,
            icon: isScanning
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.document_scanner),
            label: Text(isScanning ? 'Scanning...' : 'Scan Documents'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          SizedBox(height: 16),

          // Results Section
          if (scannedDocuments.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scanned Documents (${scannedDocuments.length})',
                  style: FlutterFlowTheme.of(context).headlineSmall,
                ),
                TextButton.icon(
                  onPressed: clearScannedDocuments,
                  icon: Icon(Icons.clear),
                  label: Text('Clear'),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: scannedDocuments.length,
                itemBuilder: (context, index) {
                  final documentPath = scannedDocuments[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.image),
                      title: Text('Image ${index + 1}'),
                      subtitle: Text(
                        documentPath,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // You can add navigation to view the image here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Image path: $documentPath')),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ] else if (!isScanning) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.document_scanner_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No images scanned yet',
                      style: FlutterFlowTheme.of(context).bodyLarge.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the scan button to start',
                      style: FlutterFlowTheme.of(context).bodyMedium.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
