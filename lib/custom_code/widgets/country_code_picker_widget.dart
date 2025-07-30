// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:country_code_picker/country_code_picker.dart';

class CountryCodePickerWidget extends StatefulWidget {
  const CountryCodePickerWidget({
    Key? key,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.onChanged,
    this.dialogTextColor,
    this.dialogBackgroundColor,
  }) : super(key: key);

  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final Future Function(String dialCode)? onChanged;
  final Color? dialogTextColor;
  final Color? dialogBackgroundColor;

  @override
  State<CountryCodePickerWidget> createState() =>
      _CountryCodePickerWidgetState();
}

class _CountryCodePickerWidgetState extends State<CountryCodePickerWidget> {
  String _selectedDialCode = '+961';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
        border: Border.all(
          color: widget.borderColor ?? Colors.transparent,
          width: widget.borderWidth ?? 1.0,
        ),
      ),
      child: CountryCodePicker(
        showOnlyCountryWhenClosed: true,
        showCountryOnly: false,
        showFlag: true,
        showFlagMain: true,
        showFlagDialog: true,
        initialSelection: _selectedDialCode,
        textStyle: TextStyle(
          fontSize: 16,
          color: FlutterFlowTheme.of(context).primaryText,
        ),
        dialogTextStyle: TextStyle(
          fontSize: 16,
          color: widget.dialogTextColor ??
              FlutterFlowTheme.of(context).primaryText,
        ),
        dialogBackgroundColor: widget.dialogBackgroundColor ?? Colors.white,
        onChanged: (country) {
          setState(() => _selectedDialCode = country.dialCode ?? '+961');
          if (widget.onChanged != null) {
            widget.onChanged!(_selectedDialCode);
          }
        },
        padding: EdgeInsets.zero,
        dialogSize: Size(
          MediaQuery.of(context).size.width * 0.8,
          MediaQuery.of(context).size.height * 0.6,
        ),
      ),
    );
  }
}
