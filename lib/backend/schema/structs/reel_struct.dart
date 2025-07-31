// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ReelStruct extends BaseStruct {
  ReelStruct({
    String? mediaUrl,
    bool? isVideo,
    String? userAvatarUrl,
    String? userName,
    String? placeAvatarUrl,
    String? placeName,
    String? placeCategory,
    int? likesCount,
    bool? isLiked,
  })  : _mediaUrl = mediaUrl,
        _isVideo = isVideo,
        _userAvatarUrl = userAvatarUrl,
        _userName = userName,
        _placeAvatarUrl = placeAvatarUrl,
        _placeName = placeName,
        _placeCategory = placeCategory,
        _likesCount = likesCount,
        _isLiked = isLiked;

  // "mediaUrl" field.
  String? _mediaUrl;
  String get mediaUrl => _mediaUrl ?? '';
  set mediaUrl(String? val) => _mediaUrl = val;

  bool hasMediaUrl() => _mediaUrl != null;

  // "isVideo" field.
  bool? _isVideo;
  bool get isVideo => _isVideo ?? false;
  set isVideo(bool? val) => _isVideo = val;

  bool hasIsVideo() => _isVideo != null;

  // "userAvatarUrl" field.
  String? _userAvatarUrl;
  String get userAvatarUrl => _userAvatarUrl ?? '';
  set userAvatarUrl(String? val) => _userAvatarUrl = val;

  bool hasUserAvatarUrl() => _userAvatarUrl != null;

  // "userName" field.
  String? _userName;
  String get userName => _userName ?? '';
  set userName(String? val) => _userName = val;

  bool hasUserName() => _userName != null;

  // "placeAvatarUrl" field.
  String? _placeAvatarUrl;
  String get placeAvatarUrl => _placeAvatarUrl ?? '';
  set placeAvatarUrl(String? val) => _placeAvatarUrl = val;

  bool hasPlaceAvatarUrl() => _placeAvatarUrl != null;

  // "placeName" field.
  String? _placeName;
  String get placeName => _placeName ?? '';
  set placeName(String? val) => _placeName = val;

  bool hasPlaceName() => _placeName != null;

  // "placeCategory" field.
  String? _placeCategory;
  String get placeCategory => _placeCategory ?? '';
  set placeCategory(String? val) => _placeCategory = val;

  bool hasPlaceCategory() => _placeCategory != null;

  // "likesCount" field.
  int? _likesCount;
  int get likesCount => _likesCount ?? 0;
  set likesCount(int? val) => _likesCount = val;

  void incrementLikesCount(int amount) => likesCount = likesCount + amount;

  bool hasLikesCount() => _likesCount != null;

  // "isLiked" field.
  bool? _isLiked;
  bool get isLiked => _isLiked ?? false;
  set isLiked(bool? val) => _isLiked = val;

  bool hasIsLiked() => _isLiked != null;

  static ReelStruct fromMap(Map<String, dynamic> data) => ReelStruct(
        mediaUrl: data['mediaUrl'] as String?,
        isVideo: data['isVideo'] as bool?,
        userAvatarUrl: data['userAvatarUrl'] as String?,
        userName: data['userName'] as String?,
        placeAvatarUrl: data['placeAvatarUrl'] as String?,
        placeName: data['placeName'] as String?,
        placeCategory: data['placeCategory'] as String?,
        likesCount: castToType<int>(data['likesCount']),
        isLiked: data['isLiked'] as bool?,
      );

  static ReelStruct? maybeFromMap(dynamic data) =>
      data is Map ? ReelStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'mediaUrl': _mediaUrl,
        'isVideo': _isVideo,
        'userAvatarUrl': _userAvatarUrl,
        'userName': _userName,
        'placeAvatarUrl': _placeAvatarUrl,
        'placeName': _placeName,
        'placeCategory': _placeCategory,
        'likesCount': _likesCount,
        'isLiked': _isLiked,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'mediaUrl': serializeParam(
          _mediaUrl,
          ParamType.String,
        ),
        'isVideo': serializeParam(
          _isVideo,
          ParamType.bool,
        ),
        'userAvatarUrl': serializeParam(
          _userAvatarUrl,
          ParamType.String,
        ),
        'userName': serializeParam(
          _userName,
          ParamType.String,
        ),
        'placeAvatarUrl': serializeParam(
          _placeAvatarUrl,
          ParamType.String,
        ),
        'placeName': serializeParam(
          _placeName,
          ParamType.String,
        ),
        'placeCategory': serializeParam(
          _placeCategory,
          ParamType.String,
        ),
        'likesCount': serializeParam(
          _likesCount,
          ParamType.int,
        ),
        'isLiked': serializeParam(
          _isLiked,
          ParamType.bool,
        ),
      }.withoutNulls;

  static ReelStruct fromSerializableMap(Map<String, dynamic> data) =>
      ReelStruct(
        mediaUrl: deserializeParam(
          data['mediaUrl'],
          ParamType.String,
          false,
        ),
        isVideo: deserializeParam(
          data['isVideo'],
          ParamType.bool,
          false,
        ),
        userAvatarUrl: deserializeParam(
          data['userAvatarUrl'],
          ParamType.String,
          false,
        ),
        userName: deserializeParam(
          data['userName'],
          ParamType.String,
          false,
        ),
        placeAvatarUrl: deserializeParam(
          data['placeAvatarUrl'],
          ParamType.String,
          false,
        ),
        placeName: deserializeParam(
          data['placeName'],
          ParamType.String,
          false,
        ),
        placeCategory: deserializeParam(
          data['placeCategory'],
          ParamType.String,
          false,
        ),
        likesCount: deserializeParam(
          data['likesCount'],
          ParamType.int,
          false,
        ),
        isLiked: deserializeParam(
          data['isLiked'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'ReelStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ReelStruct &&
        mediaUrl == other.mediaUrl &&
        isVideo == other.isVideo &&
        userAvatarUrl == other.userAvatarUrl &&
        userName == other.userName &&
        placeAvatarUrl == other.placeAvatarUrl &&
        placeName == other.placeName &&
        placeCategory == other.placeCategory &&
        likesCount == other.likesCount &&
        isLiked == other.isLiked;
  }

  @override
  int get hashCode => const ListEquality().hash([
        mediaUrl,
        isVideo,
        userAvatarUrl,
        userName,
        placeAvatarUrl,
        placeName,
        placeCategory,
        likesCount,
        isLiked
      ]);
}

ReelStruct createReelStruct({
  String? mediaUrl,
  bool? isVideo,
  String? userAvatarUrl,
  String? userName,
  String? placeAvatarUrl,
  String? placeName,
  String? placeCategory,
  int? likesCount,
  bool? isLiked,
}) =>
    ReelStruct(
      mediaUrl: mediaUrl,
      isVideo: isVideo,
      userAvatarUrl: userAvatarUrl,
      userName: userName,
      placeAvatarUrl: placeAvatarUrl,
      placeName: placeName,
      placeCategory: placeCategory,
      likesCount: likesCount,
      isLiked: isLiked,
    );
