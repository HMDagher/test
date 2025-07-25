// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ActionResponseStruct extends BaseStruct {
  ActionResponseStruct({
    /// success → true if the action executes successfully, false if an error
    /// occurs.
    bool? success,

    /// error → The error message from the exception (if any).
    String? error,

    /// errorMsg → A friendly user-facing error message (default: "Could not
    /// process.
    ///
    /// Try again later").
    String? errorMsg,
  })  : _success = success,
        _error = error,
        _errorMsg = errorMsg;

  // "success" field.
  bool? _success;
  bool get success => _success ?? false;
  set success(bool? val) => _success = val;

  bool hasSuccess() => _success != null;

  // "error" field.
  String? _error;
  String get error => _error ?? '';
  set error(String? val) => _error = val;

  bool hasError() => _error != null;

  // "errorMsg" field.
  String? _errorMsg;
  String get errorMsg => _errorMsg ?? '';
  set errorMsg(String? val) => _errorMsg = val;

  bool hasErrorMsg() => _errorMsg != null;

  static ActionResponseStruct fromMap(Map<String, dynamic> data) =>
      ActionResponseStruct(
        success: data['success'] as bool?,
        error: data['error'] as String?,
        errorMsg: data['errorMsg'] as String?,
      );

  static ActionResponseStruct? maybeFromMap(dynamic data) => data is Map
      ? ActionResponseStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'success': _success,
        'error': _error,
        'errorMsg': _errorMsg,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'success': serializeParam(
          _success,
          ParamType.bool,
        ),
        'error': serializeParam(
          _error,
          ParamType.String,
        ),
        'errorMsg': serializeParam(
          _errorMsg,
          ParamType.String,
        ),
      }.withoutNulls;

  static ActionResponseStruct fromSerializableMap(Map<String, dynamic> data) =>
      ActionResponseStruct(
        success: deserializeParam(
          data['success'],
          ParamType.bool,
          false,
        ),
        error: deserializeParam(
          data['error'],
          ParamType.String,
          false,
        ),
        errorMsg: deserializeParam(
          data['errorMsg'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ActionResponseStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ActionResponseStruct &&
        success == other.success &&
        error == other.error &&
        errorMsg == other.errorMsg;
  }

  @override
  int get hashCode => const ListEquality().hash([success, error, errorMsg]);
}

ActionResponseStruct createActionResponseStruct({
  bool? success,
  String? error,
  String? errorMsg,
}) =>
    ActionResponseStruct(
      success: success,
      error: error,
      errorMsg: errorMsg,
    );
