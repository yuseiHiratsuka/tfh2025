// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Submission {
  /// ドキュメントID
  String get id;

  /// 投稿者ID
  String get userId;

  /// 投稿者名（非正規化）
  String get userName;

  /// 投稿日時
  @TimestampConverter()
  DateTime get createdAt;

  /// 投稿時のシーケンス番号
  int get sequenceNumber;

  /// Storage公開URL
  String get imageUrl;

  /// Storage内パス
  String get storagePath;

  /// 処理状態
  SubmissionStatus get status;

  /// AI認識結果
  AIResult? get aiResult;

  /// 検証結果
  Validation? get validation;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SubmissionCopyWith<Submission> get copyWith =>
      _$SubmissionCopyWithImpl<Submission>(this as Submission, _$identity);

  /// Serializes this Submission to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Submission &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.sequenceNumber, sequenceNumber) ||
                other.sequenceNumber == sequenceNumber) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.aiResult, aiResult) ||
                other.aiResult == aiResult) &&
            (identical(other.validation, validation) ||
                other.validation == validation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, userName, createdAt,
      sequenceNumber, imageUrl, storagePath, status, aiResult, validation);

  @override
  String toString() {
    return 'Submission(id: $id, userId: $userId, userName: $userName, createdAt: $createdAt, sequenceNumber: $sequenceNumber, imageUrl: $imageUrl, storagePath: $storagePath, status: $status, aiResult: $aiResult, validation: $validation)';
  }
}

/// @nodoc
abstract mixin class $SubmissionCopyWith<$Res> {
  factory $SubmissionCopyWith(
          Submission value, $Res Function(Submission) _then) =
      _$SubmissionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String userName,
      @TimestampConverter() DateTime createdAt,
      int sequenceNumber,
      String imageUrl,
      String storagePath,
      SubmissionStatus status,
      AIResult? aiResult,
      Validation? validation});

  $AIResultCopyWith<$Res>? get aiResult;
  $ValidationCopyWith<$Res>? get validation;
}

/// @nodoc
class _$SubmissionCopyWithImpl<$Res> implements $SubmissionCopyWith<$Res> {
  _$SubmissionCopyWithImpl(this._self, this._then);

  final Submission _self;
  final $Res Function(Submission) _then;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? createdAt = null,
    Object? sequenceNumber = null,
    Object? imageUrl = null,
    Object? storagePath = null,
    Object? status = null,
    Object? aiResult = freezed,
    Object? validation = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sequenceNumber: null == sequenceNumber
          ? _self.sequenceNumber
          : sequenceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      storagePath: null == storagePath
          ? _self.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubmissionStatus,
      aiResult: freezed == aiResult
          ? _self.aiResult
          : aiResult // ignore: cast_nullable_to_non_nullable
              as AIResult?,
      validation: freezed == validation
          ? _self.validation
          : validation // ignore: cast_nullable_to_non_nullable
              as Validation?,
    ));
  }

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AIResultCopyWith<$Res>? get aiResult {
    if (_self.aiResult == null) {
      return null;
    }

    return $AIResultCopyWith<$Res>(_self.aiResult!, (value) {
      return _then(_self.copyWith(aiResult: value));
    });
  }

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ValidationCopyWith<$Res>? get validation {
    if (_self.validation == null) {
      return null;
    }

    return $ValidationCopyWith<$Res>(_self.validation!, (value) {
      return _then(_self.copyWith(validation: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Submission].
extension SubmissionPatterns on Submission {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Submission value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Submission() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Submission value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Submission():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Submission value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Submission() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String userId,
            String userName,
            @TimestampConverter() DateTime createdAt,
            int sequenceNumber,
            String imageUrl,
            String storagePath,
            SubmissionStatus status,
            AIResult? aiResult,
            Validation? validation)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Submission() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.userName,
            _that.createdAt,
            _that.sequenceNumber,
            _that.imageUrl,
            _that.storagePath,
            _that.status,
            _that.aiResult,
            _that.validation);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String userId,
            String userName,
            @TimestampConverter() DateTime createdAt,
            int sequenceNumber,
            String imageUrl,
            String storagePath,
            SubmissionStatus status,
            AIResult? aiResult,
            Validation? validation)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Submission():
        return $default(
            _that.id,
            _that.userId,
            _that.userName,
            _that.createdAt,
            _that.sequenceNumber,
            _that.imageUrl,
            _that.storagePath,
            _that.status,
            _that.aiResult,
            _that.validation);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String userId,
            String userName,
            @TimestampConverter() DateTime createdAt,
            int sequenceNumber,
            String imageUrl,
            String storagePath,
            SubmissionStatus status,
            AIResult? aiResult,
            Validation? validation)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Submission() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.userName,
            _that.createdAt,
            _that.sequenceNumber,
            _that.imageUrl,
            _that.storagePath,
            _that.status,
            _that.aiResult,
            _that.validation);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Submission extends Submission {
  const _Submission(
      {required this.id,
      required this.userId,
      required this.userName,
      @TimestampConverter() required this.createdAt,
      required this.sequenceNumber,
      required this.imageUrl,
      required this.storagePath,
      required this.status,
      this.aiResult,
      this.validation})
      : super._();
  factory _Submission.fromJson(Map<String, dynamic> json) =>
      _$SubmissionFromJson(json);

  /// ドキュメントID
  @override
  final String id;

  /// 投稿者ID
  @override
  final String userId;

  /// 投稿者名（非正規化）
  @override
  final String userName;

  /// 投稿日時
  @override
  @TimestampConverter()
  final DateTime createdAt;

  /// 投稿時のシーケンス番号
  @override
  final int sequenceNumber;

  /// Storage公開URL
  @override
  final String imageUrl;

  /// Storage内パス
  @override
  final String storagePath;

  /// 処理状態
  @override
  final SubmissionStatus status;

  /// AI認識結果
  @override
  final AIResult? aiResult;

  /// 検証結果
  @override
  final Validation? validation;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SubmissionCopyWith<_Submission> get copyWith =>
      __$SubmissionCopyWithImpl<_Submission>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SubmissionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Submission &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.sequenceNumber, sequenceNumber) ||
                other.sequenceNumber == sequenceNumber) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.storagePath, storagePath) ||
                other.storagePath == storagePath) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.aiResult, aiResult) ||
                other.aiResult == aiResult) &&
            (identical(other.validation, validation) ||
                other.validation == validation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, userName, createdAt,
      sequenceNumber, imageUrl, storagePath, status, aiResult, validation);

  @override
  String toString() {
    return 'Submission(id: $id, userId: $userId, userName: $userName, createdAt: $createdAt, sequenceNumber: $sequenceNumber, imageUrl: $imageUrl, storagePath: $storagePath, status: $status, aiResult: $aiResult, validation: $validation)';
  }
}

/// @nodoc
abstract mixin class _$SubmissionCopyWith<$Res>
    implements $SubmissionCopyWith<$Res> {
  factory _$SubmissionCopyWith(
          _Submission value, $Res Function(_Submission) _then) =
      __$SubmissionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String userName,
      @TimestampConverter() DateTime createdAt,
      int sequenceNumber,
      String imageUrl,
      String storagePath,
      SubmissionStatus status,
      AIResult? aiResult,
      Validation? validation});

  @override
  $AIResultCopyWith<$Res>? get aiResult;
  @override
  $ValidationCopyWith<$Res>? get validation;
}

/// @nodoc
class __$SubmissionCopyWithImpl<$Res> implements _$SubmissionCopyWith<$Res> {
  __$SubmissionCopyWithImpl(this._self, this._then);

  final _Submission _self;
  final $Res Function(_Submission) _then;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = null,
    Object? createdAt = null,
    Object? sequenceNumber = null,
    Object? imageUrl = null,
    Object? storagePath = null,
    Object? status = null,
    Object? aiResult = freezed,
    Object? validation = freezed,
  }) {
    return _then(_Submission(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sequenceNumber: null == sequenceNumber
          ? _self.sequenceNumber
          : sequenceNumber // ignore: cast_nullable_to_non_nullable
              as int,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      storagePath: null == storagePath
          ? _self.storagePath
          : storagePath // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubmissionStatus,
      aiResult: freezed == aiResult
          ? _self.aiResult
          : aiResult // ignore: cast_nullable_to_non_nullable
              as AIResult?,
      validation: freezed == validation
          ? _self.validation
          : validation // ignore: cast_nullable_to_non_nullable
              as Validation?,
    ));
  }

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AIResultCopyWith<$Res>? get aiResult {
    if (_self.aiResult == null) {
      return null;
    }

    return $AIResultCopyWith<$Res>(_self.aiResult!, (value) {
      return _then(_self.copyWith(aiResult: value));
    });
  }

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ValidationCopyWith<$Res>? get validation {
    if (_self.validation == null) {
      return null;
    }

    return $ValidationCopyWith<$Res>(_self.validation!, (value) {
      return _then(_self.copyWith(validation: value));
    });
  }
}

// dart format on
