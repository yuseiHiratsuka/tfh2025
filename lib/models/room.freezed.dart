// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Room {
  /// ドキュメントID
  String get id;

  /// 作成日時
  @TimestampConverter()
  DateTime get createdAt;

  /// 更新日時
  @TimestampConverter()
  DateTime get updatedAt;

  /// ゲーム状態
  RoomStatus get status;

  /// 開始文字（1文字、ひらがな）
  String get startCharacter;

  /// ゴール文字（1文字、ひらがな）
  String get goalCharacter;

  /// 最大参加人数
  int get maxPlayers;

  /// 全体の制限時間（秒）
  int get timeLimit;

  /// 現在のお題文字（1文字、ひらがな）
  String get currentCharacter;

  /// シーケンス番号（楽観的ロック用）
  int get currentSequence;

  /// 使用済みワード配列
  List<String> get usedWords;

  /// チェーン数（採用された回数）
  int get chainCount;

  /// ゴール到達フラグ
  bool get isGoalReached;

  /// 総投稿数
  int get totalSubmissions;

  /// 総参加者数
  int get totalParticipants;

  /// 準備完了している参加者数
  @JsonKey(defaultValue: 0)
  int get readyCount;

  /// 合言葉（ルーム検索用）
  String? get password;

  /// 失敗理由
  FailureReason? get failureReason;

  /// ゲーム開始日時
  @NullableTimestampConverter()
  DateTime? get startedAt;

  /// ゴール到達者のuserId
  String? get goalReachedBy;

  /// 終了日時
  @NullableTimestampConverter()
  DateTime? get finishedAt;

  /// ゲームスコア
  int? get score;

  /// 時間ボーナス
  int? get timeBonus;

  /// チェーンボーナス
  int? get chainBonus;

  /// 残り時間（秒）
  int? get remainingTime;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RoomCopyWith<Room> get copyWith =>
      _$RoomCopyWithImpl<Room>(this as Room, _$identity);

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Room &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startCharacter, startCharacter) ||
                other.startCharacter == startCharacter) &&
            (identical(other.goalCharacter, goalCharacter) ||
                other.goalCharacter == goalCharacter) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.timeLimit, timeLimit) ||
                other.timeLimit == timeLimit) &&
            (identical(other.currentCharacter, currentCharacter) ||
                other.currentCharacter == currentCharacter) &&
            (identical(other.currentSequence, currentSequence) ||
                other.currentSequence == currentSequence) &&
            const DeepCollectionEquality().equals(other.usedWords, usedWords) &&
            (identical(other.chainCount, chainCount) ||
                other.chainCount == chainCount) &&
            (identical(other.isGoalReached, isGoalReached) ||
                other.isGoalReached == isGoalReached) &&
            (identical(other.totalSubmissions, totalSubmissions) ||
                other.totalSubmissions == totalSubmissions) &&
            (identical(other.totalParticipants, totalParticipants) ||
                other.totalParticipants == totalParticipants) &&
            (identical(other.readyCount, readyCount) ||
                other.readyCount == readyCount) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.failureReason, failureReason) ||
                other.failureReason == failureReason) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.goalReachedBy, goalReachedBy) ||
                other.goalReachedBy == goalReachedBy) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.timeBonus, timeBonus) ||
                other.timeBonus == timeBonus) &&
            (identical(other.chainBonus, chainBonus) ||
                other.chainBonus == chainBonus) &&
            (identical(other.remainingTime, remainingTime) ||
                other.remainingTime == remainingTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        createdAt,
        updatedAt,
        status,
        startCharacter,
        goalCharacter,
        maxPlayers,
        timeLimit,
        currentCharacter,
        currentSequence,
        const DeepCollectionEquality().hash(usedWords),
        chainCount,
        isGoalReached,
        totalSubmissions,
        totalParticipants,
        readyCount,
        password,
        failureReason,
        startedAt,
        goalReachedBy,
        finishedAt,
        score,
        timeBonus,
        chainBonus,
        remainingTime
      ]);

  @override
  String toString() {
    return 'Room(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, startCharacter: $startCharacter, goalCharacter: $goalCharacter, maxPlayers: $maxPlayers, timeLimit: $timeLimit, currentCharacter: $currentCharacter, currentSequence: $currentSequence, usedWords: $usedWords, chainCount: $chainCount, isGoalReached: $isGoalReached, totalSubmissions: $totalSubmissions, totalParticipants: $totalParticipants, readyCount: $readyCount, password: $password, failureReason: $failureReason, startedAt: $startedAt, goalReachedBy: $goalReachedBy, finishedAt: $finishedAt, score: $score, timeBonus: $timeBonus, chainBonus: $chainBonus, remainingTime: $remainingTime)';
  }
}

/// @nodoc
abstract mixin class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) _then) =
      _$RoomCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      RoomStatus status,
      String startCharacter,
      String goalCharacter,
      int maxPlayers,
      int timeLimit,
      String currentCharacter,
      int currentSequence,
      List<String> usedWords,
      int chainCount,
      bool isGoalReached,
      int totalSubmissions,
      int totalParticipants,
      @JsonKey(defaultValue: 0) int readyCount,
      String? password,
      FailureReason? failureReason,
      @NullableTimestampConverter() DateTime? startedAt,
      String? goalReachedBy,
      @NullableTimestampConverter() DateTime? finishedAt,
      int? score,
      int? timeBonus,
      int? chainBonus,
      int? remainingTime});
}

/// @nodoc
class _$RoomCopyWithImpl<$Res> implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._self, this._then);

  final Room _self;
  final $Res Function(Room) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? status = null,
    Object? startCharacter = null,
    Object? goalCharacter = null,
    Object? maxPlayers = null,
    Object? timeLimit = null,
    Object? currentCharacter = null,
    Object? currentSequence = null,
    Object? usedWords = null,
    Object? chainCount = null,
    Object? isGoalReached = null,
    Object? totalSubmissions = null,
    Object? totalParticipants = null,
    Object? readyCount = null,
    Object? password = freezed,
    Object? failureReason = freezed,
    Object? startedAt = freezed,
    Object? goalReachedBy = freezed,
    Object? finishedAt = freezed,
    Object? score = freezed,
    Object? timeBonus = freezed,
    Object? chainBonus = freezed,
    Object? remainingTime = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomStatus,
      startCharacter: null == startCharacter
          ? _self.startCharacter
          : startCharacter // ignore: cast_nullable_to_non_nullable
              as String,
      goalCharacter: null == goalCharacter
          ? _self.goalCharacter
          : goalCharacter // ignore: cast_nullable_to_non_nullable
              as String,
      maxPlayers: null == maxPlayers
          ? _self.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      timeLimit: null == timeLimit
          ? _self.timeLimit
          : timeLimit // ignore: cast_nullable_to_non_nullable
              as int,
      currentCharacter: null == currentCharacter
          ? _self.currentCharacter
          : currentCharacter // ignore: cast_nullable_to_non_nullable
              as String,
      currentSequence: null == currentSequence
          ? _self.currentSequence
          : currentSequence // ignore: cast_nullable_to_non_nullable
              as int,
      usedWords: null == usedWords
          ? _self.usedWords
          : usedWords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      chainCount: null == chainCount
          ? _self.chainCount
          : chainCount // ignore: cast_nullable_to_non_nullable
              as int,
      isGoalReached: null == isGoalReached
          ? _self.isGoalReached
          : isGoalReached // ignore: cast_nullable_to_non_nullable
              as bool,
      totalSubmissions: null == totalSubmissions
          ? _self.totalSubmissions
          : totalSubmissions // ignore: cast_nullable_to_non_nullable
              as int,
      totalParticipants: null == totalParticipants
          ? _self.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      readyCount: null == readyCount
          ? _self.readyCount
          : readyCount // ignore: cast_nullable_to_non_nullable
              as int,
      password: freezed == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      failureReason: freezed == failureReason
          ? _self.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as FailureReason?,
      startedAt: freezed == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      goalReachedBy: freezed == goalReachedBy
          ? _self.goalReachedBy
          : goalReachedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      finishedAt: freezed == finishedAt
          ? _self.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      score: freezed == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int?,
      timeBonus: freezed == timeBonus
          ? _self.timeBonus
          : timeBonus // ignore: cast_nullable_to_non_nullable
              as int?,
      chainBonus: freezed == chainBonus
          ? _self.chainBonus
          : chainBonus // ignore: cast_nullable_to_non_nullable
              as int?,
      remainingTime: freezed == remainingTime
          ? _self.remainingTime
          : remainingTime // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Room].
extension RoomPatterns on Room {
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
    TResult Function(_Room value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Room() when $default != null:
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
    TResult Function(_Room value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Room():
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
    TResult? Function(_Room value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Room() when $default != null:
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
            @TimestampConverter() DateTime createdAt,
            @TimestampConverter() DateTime updatedAt,
            RoomStatus status,
            String startCharacter,
            String goalCharacter,
            int maxPlayers,
            int timeLimit,
            String currentCharacter,
            int currentSequence,
            List<String> usedWords,
            int chainCount,
            bool isGoalReached,
            int totalSubmissions,
            int totalParticipants,
            @JsonKey(defaultValue: 0) int readyCount,
            String? password,
            FailureReason? failureReason,
            @NullableTimestampConverter() DateTime? startedAt,
            String? goalReachedBy,
            @NullableTimestampConverter() DateTime? finishedAt,
            int? score,
            int? timeBonus,
            int? chainBonus,
            int? remainingTime)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Room() when $default != null:
        return $default(
            _that.id,
            _that.createdAt,
            _that.updatedAt,
            _that.status,
            _that.startCharacter,
            _that.goalCharacter,
            _that.maxPlayers,
            _that.timeLimit,
            _that.currentCharacter,
            _that.currentSequence,
            _that.usedWords,
            _that.chainCount,
            _that.isGoalReached,
            _that.totalSubmissions,
            _that.totalParticipants,
            _that.readyCount,
            _that.password,
            _that.failureReason,
            _that.startedAt,
            _that.goalReachedBy,
            _that.finishedAt,
            _that.score,
            _that.timeBonus,
            _that.chainBonus,
            _that.remainingTime);
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
            @TimestampConverter() DateTime createdAt,
            @TimestampConverter() DateTime updatedAt,
            RoomStatus status,
            String startCharacter,
            String goalCharacter,
            int maxPlayers,
            int timeLimit,
            String currentCharacter,
            int currentSequence,
            List<String> usedWords,
            int chainCount,
            bool isGoalReached,
            int totalSubmissions,
            int totalParticipants,
            @JsonKey(defaultValue: 0) int readyCount,
            String? password,
            FailureReason? failureReason,
            @NullableTimestampConverter() DateTime? startedAt,
            String? goalReachedBy,
            @NullableTimestampConverter() DateTime? finishedAt,
            int? score,
            int? timeBonus,
            int? chainBonus,
            int? remainingTime)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Room():
        return $default(
            _that.id,
            _that.createdAt,
            _that.updatedAt,
            _that.status,
            _that.startCharacter,
            _that.goalCharacter,
            _that.maxPlayers,
            _that.timeLimit,
            _that.currentCharacter,
            _that.currentSequence,
            _that.usedWords,
            _that.chainCount,
            _that.isGoalReached,
            _that.totalSubmissions,
            _that.totalParticipants,
            _that.readyCount,
            _that.password,
            _that.failureReason,
            _that.startedAt,
            _that.goalReachedBy,
            _that.finishedAt,
            _that.score,
            _that.timeBonus,
            _that.chainBonus,
            _that.remainingTime);
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
            @TimestampConverter() DateTime createdAt,
            @TimestampConverter() DateTime updatedAt,
            RoomStatus status,
            String startCharacter,
            String goalCharacter,
            int maxPlayers,
            int timeLimit,
            String currentCharacter,
            int currentSequence,
            List<String> usedWords,
            int chainCount,
            bool isGoalReached,
            int totalSubmissions,
            int totalParticipants,
            @JsonKey(defaultValue: 0) int readyCount,
            String? password,
            FailureReason? failureReason,
            @NullableTimestampConverter() DateTime? startedAt,
            String? goalReachedBy,
            @NullableTimestampConverter() DateTime? finishedAt,
            int? score,
            int? timeBonus,
            int? chainBonus,
            int? remainingTime)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Room() when $default != null:
        return $default(
            _that.id,
            _that.createdAt,
            _that.updatedAt,
            _that.status,
            _that.startCharacter,
            _that.goalCharacter,
            _that.maxPlayers,
            _that.timeLimit,
            _that.currentCharacter,
            _that.currentSequence,
            _that.usedWords,
            _that.chainCount,
            _that.isGoalReached,
            _that.totalSubmissions,
            _that.totalParticipants,
            _that.readyCount,
            _that.password,
            _that.failureReason,
            _that.startedAt,
            _that.goalReachedBy,
            _that.finishedAt,
            _that.score,
            _that.timeBonus,
            _that.chainBonus,
            _that.remainingTime);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Room extends Room {
  const _Room(
      {required this.id,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt,
      required this.status,
      required this.startCharacter,
      required this.goalCharacter,
      required this.maxPlayers,
      required this.timeLimit,
      required this.currentCharacter,
      required this.currentSequence,
      required final List<String> usedWords,
      required this.chainCount,
      required this.isGoalReached,
      required this.totalSubmissions,
      required this.totalParticipants,
      @JsonKey(defaultValue: 0) required this.readyCount,
      this.password,
      this.failureReason,
      @NullableTimestampConverter() this.startedAt,
      this.goalReachedBy,
      @NullableTimestampConverter() this.finishedAt,
      this.score,
      this.timeBonus,
      this.chainBonus,
      this.remainingTime})
      : _usedWords = usedWords,
        super._();
  factory _Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  /// ドキュメントID
  @override
  final String id;

  /// 作成日時
  @override
  @TimestampConverter()
  final DateTime createdAt;

  /// 更新日時
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  /// ゲーム状態
  @override
  final RoomStatus status;

  /// 開始文字（1文字、ひらがな）
  @override
  final String startCharacter;

  /// ゴール文字（1文字、ひらがな）
  @override
  final String goalCharacter;

  /// 最大参加人数
  @override
  final int maxPlayers;

  /// 全体の制限時間（秒）
  @override
  final int timeLimit;

  /// 現在のお題文字（1文字、ひらがな）
  @override
  final String currentCharacter;

  /// シーケンス番号（楽観的ロック用）
  @override
  final int currentSequence;

  /// 使用済みワード配列
  final List<String> _usedWords;

  /// 使用済みワード配列
  @override
  List<String> get usedWords {
    if (_usedWords is EqualUnmodifiableListView) return _usedWords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_usedWords);
  }

  /// チェーン数（採用された回数）
  @override
  final int chainCount;

  /// ゴール到達フラグ
  @override
  final bool isGoalReached;

  /// 総投稿数
  @override
  final int totalSubmissions;

  /// 総参加者数
  @override
  final int totalParticipants;

  /// 準備完了している参加者数
  @override
  @JsonKey(defaultValue: 0)
  final int readyCount;

  /// 合言葉（ルーム検索用）
  @override
  final String? password;

  /// 失敗理由
  @override
  final FailureReason? failureReason;

  /// ゲーム開始日時
  @override
  @NullableTimestampConverter()
  final DateTime? startedAt;

  /// ゴール到達者のuserId
  @override
  final String? goalReachedBy;

  /// 終了日時
  @override
  @NullableTimestampConverter()
  final DateTime? finishedAt;

  /// ゲームスコア
  @override
  final int? score;

  /// 時間ボーナス
  @override
  final int? timeBonus;

  /// チェーンボーナス
  @override
  final int? chainBonus;

  /// 残り時間（秒）
  @override
  final int? remainingTime;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RoomCopyWith<_Room> get copyWith =>
      __$RoomCopyWithImpl<_Room>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$RoomToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Room &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startCharacter, startCharacter) ||
                other.startCharacter == startCharacter) &&
            (identical(other.goalCharacter, goalCharacter) ||
                other.goalCharacter == goalCharacter) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.timeLimit, timeLimit) ||
                other.timeLimit == timeLimit) &&
            (identical(other.currentCharacter, currentCharacter) ||
                other.currentCharacter == currentCharacter) &&
            (identical(other.currentSequence, currentSequence) ||
                other.currentSequence == currentSequence) &&
            const DeepCollectionEquality()
                .equals(other._usedWords, _usedWords) &&
            (identical(other.chainCount, chainCount) ||
                other.chainCount == chainCount) &&
            (identical(other.isGoalReached, isGoalReached) ||
                other.isGoalReached == isGoalReached) &&
            (identical(other.totalSubmissions, totalSubmissions) ||
                other.totalSubmissions == totalSubmissions) &&
            (identical(other.totalParticipants, totalParticipants) ||
                other.totalParticipants == totalParticipants) &&
            (identical(other.readyCount, readyCount) ||
                other.readyCount == readyCount) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.failureReason, failureReason) ||
                other.failureReason == failureReason) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.goalReachedBy, goalReachedBy) ||
                other.goalReachedBy == goalReachedBy) &&
            (identical(other.finishedAt, finishedAt) ||
                other.finishedAt == finishedAt) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.timeBonus, timeBonus) ||
                other.timeBonus == timeBonus) &&
            (identical(other.chainBonus, chainBonus) ||
                other.chainBonus == chainBonus) &&
            (identical(other.remainingTime, remainingTime) ||
                other.remainingTime == remainingTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        createdAt,
        updatedAt,
        status,
        startCharacter,
        goalCharacter,
        maxPlayers,
        timeLimit,
        currentCharacter,
        currentSequence,
        const DeepCollectionEquality().hash(_usedWords),
        chainCount,
        isGoalReached,
        totalSubmissions,
        totalParticipants,
        readyCount,
        password,
        failureReason,
        startedAt,
        goalReachedBy,
        finishedAt,
        score,
        timeBonus,
        chainBonus,
        remainingTime
      ]);

  @override
  String toString() {
    return 'Room(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, startCharacter: $startCharacter, goalCharacter: $goalCharacter, maxPlayers: $maxPlayers, timeLimit: $timeLimit, currentCharacter: $currentCharacter, currentSequence: $currentSequence, usedWords: $usedWords, chainCount: $chainCount, isGoalReached: $isGoalReached, totalSubmissions: $totalSubmissions, totalParticipants: $totalParticipants, readyCount: $readyCount, password: $password, failureReason: $failureReason, startedAt: $startedAt, goalReachedBy: $goalReachedBy, finishedAt: $finishedAt, score: $score, timeBonus: $timeBonus, chainBonus: $chainBonus, remainingTime: $remainingTime)';
  }
}

/// @nodoc
abstract mixin class _$RoomCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$RoomCopyWith(_Room value, $Res Function(_Room) _then) =
      __$RoomCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      RoomStatus status,
      String startCharacter,
      String goalCharacter,
      int maxPlayers,
      int timeLimit,
      String currentCharacter,
      int currentSequence,
      List<String> usedWords,
      int chainCount,
      bool isGoalReached,
      int totalSubmissions,
      int totalParticipants,
      @JsonKey(defaultValue: 0) int readyCount,
      String? password,
      FailureReason? failureReason,
      @NullableTimestampConverter() DateTime? startedAt,
      String? goalReachedBy,
      @NullableTimestampConverter() DateTime? finishedAt,
      int? score,
      int? timeBonus,
      int? chainBonus,
      int? remainingTime});
}

/// @nodoc
class __$RoomCopyWithImpl<$Res> implements _$RoomCopyWith<$Res> {
  __$RoomCopyWithImpl(this._self, this._then);

  final _Room _self;
  final $Res Function(_Room) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? status = null,
    Object? startCharacter = null,
    Object? goalCharacter = null,
    Object? maxPlayers = null,
    Object? timeLimit = null,
    Object? currentCharacter = null,
    Object? currentSequence = null,
    Object? usedWords = null,
    Object? chainCount = null,
    Object? isGoalReached = null,
    Object? totalSubmissions = null,
    Object? totalParticipants = null,
    Object? readyCount = null,
    Object? password = freezed,
    Object? failureReason = freezed,
    Object? startedAt = freezed,
    Object? goalReachedBy = freezed,
    Object? finishedAt = freezed,
    Object? score = freezed,
    Object? timeBonus = freezed,
    Object? chainBonus = freezed,
    Object? remainingTime = freezed,
  }) {
    return _then(_Room(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as RoomStatus,
      startCharacter: null == startCharacter
          ? _self.startCharacter
          : startCharacter // ignore: cast_nullable_to_non_nullable
              as String,
      goalCharacter: null == goalCharacter
          ? _self.goalCharacter
          : goalCharacter // ignore: cast_nullable_to_non_nullable
              as String,
      maxPlayers: null == maxPlayers
          ? _self.maxPlayers
          : maxPlayers // ignore: cast_nullable_to_non_nullable
              as int,
      timeLimit: null == timeLimit
          ? _self.timeLimit
          : timeLimit // ignore: cast_nullable_to_non_nullable
              as int,
      currentCharacter: null == currentCharacter
          ? _self.currentCharacter
          : currentCharacter // ignore: cast_nullable_to_non_nullable
              as String,
      currentSequence: null == currentSequence
          ? _self.currentSequence
          : currentSequence // ignore: cast_nullable_to_non_nullable
              as int,
      usedWords: null == usedWords
          ? _self._usedWords
          : usedWords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      chainCount: null == chainCount
          ? _self.chainCount
          : chainCount // ignore: cast_nullable_to_non_nullable
              as int,
      isGoalReached: null == isGoalReached
          ? _self.isGoalReached
          : isGoalReached // ignore: cast_nullable_to_non_nullable
              as bool,
      totalSubmissions: null == totalSubmissions
          ? _self.totalSubmissions
          : totalSubmissions // ignore: cast_nullable_to_non_nullable
              as int,
      totalParticipants: null == totalParticipants
          ? _self.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      readyCount: null == readyCount
          ? _self.readyCount
          : readyCount // ignore: cast_nullable_to_non_nullable
              as int,
      password: freezed == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String?,
      failureReason: freezed == failureReason
          ? _self.failureReason
          : failureReason // ignore: cast_nullable_to_non_nullable
              as FailureReason?,
      startedAt: freezed == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      goalReachedBy: freezed == goalReachedBy
          ? _self.goalReachedBy
          : goalReachedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      finishedAt: freezed == finishedAt
          ? _self.finishedAt
          : finishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      score: freezed == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as int?,
      timeBonus: freezed == timeBonus
          ? _self.timeBonus
          : timeBonus // ignore: cast_nullable_to_non_nullable
              as int?,
      chainBonus: freezed == chainBonus
          ? _self.chainBonus
          : chainBonus // ignore: cast_nullable_to_non_nullable
              as int?,
      remainingTime: freezed == remainingTime
          ? _self.remainingTime
          : remainingTime // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
