// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AIResult {

/// 認識された単語（ひらがな）
 String get word;/// 信頼度（0.0〜1.0）
 double get confidence;/// 最初の文字（ひらがな1文字）
 String get firstChar;/// 最後の文字（ひらがな1文字）
 String get lastChar;/// 認識完了日時
@TimestampConverter() DateTime get recognizedAt;
/// Create a copy of AIResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIResultCopyWith<AIResult> get copyWith => _$AIResultCopyWithImpl<AIResult>(this as AIResult, _$identity);

  /// Serializes this AIResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIResult&&(identical(other.word, word) || other.word == word)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.firstChar, firstChar) || other.firstChar == firstChar)&&(identical(other.lastChar, lastChar) || other.lastChar == lastChar)&&(identical(other.recognizedAt, recognizedAt) || other.recognizedAt == recognizedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,confidence,firstChar,lastChar,recognizedAt);

@override
String toString() {
  return 'AIResult(word: $word, confidence: $confidence, firstChar: $firstChar, lastChar: $lastChar, recognizedAt: $recognizedAt)';
}


}

/// @nodoc
abstract mixin class $AIResultCopyWith<$Res>  {
  factory $AIResultCopyWith(AIResult value, $Res Function(AIResult) _then) = _$AIResultCopyWithImpl;
@useResult
$Res call({
 String word, double confidence, String firstChar, String lastChar,@TimestampConverter() DateTime recognizedAt
});




}
/// @nodoc
class _$AIResultCopyWithImpl<$Res>
    implements $AIResultCopyWith<$Res> {
  _$AIResultCopyWithImpl(this._self, this._then);

  final AIResult _self;
  final $Res Function(AIResult) _then;

/// Create a copy of AIResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? word = null,Object? confidence = null,Object? firstChar = null,Object? lastChar = null,Object? recognizedAt = null,}) {
  return _then(_self.copyWith(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,firstChar: null == firstChar ? _self.firstChar : firstChar // ignore: cast_nullable_to_non_nullable
as String,lastChar: null == lastChar ? _self.lastChar : lastChar // ignore: cast_nullable_to_non_nullable
as String,recognizedAt: null == recognizedAt ? _self.recognizedAt : recognizedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AIResult].
extension AIResultPatterns on AIResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIResult() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIResult value)  $default,){
final _that = this;
switch (_that) {
case _AIResult():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIResult value)?  $default,){
final _that = this;
switch (_that) {
case _AIResult() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String word,  double confidence,  String firstChar,  String lastChar, @TimestampConverter()  DateTime recognizedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIResult() when $default != null:
return $default(_that.word,_that.confidence,_that.firstChar,_that.lastChar,_that.recognizedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String word,  double confidence,  String firstChar,  String lastChar, @TimestampConverter()  DateTime recognizedAt)  $default,) {final _that = this;
switch (_that) {
case _AIResult():
return $default(_that.word,_that.confidence,_that.firstChar,_that.lastChar,_that.recognizedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String word,  double confidence,  String firstChar,  String lastChar, @TimestampConverter()  DateTime recognizedAt)?  $default,) {final _that = this;
switch (_that) {
case _AIResult() when $default != null:
return $default(_that.word,_that.confidence,_that.firstChar,_that.lastChar,_that.recognizedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AIResult extends AIResult {
  const _AIResult({required this.word, required this.confidence, required this.firstChar, required this.lastChar, @TimestampConverter() required this.recognizedAt}): super._();
  factory _AIResult.fromJson(Map<String, dynamic> json) => _$AIResultFromJson(json);

/// 認識された単語（ひらがな）
@override final  String word;
/// 信頼度（0.0〜1.0）
@override final  double confidence;
/// 最初の文字（ひらがな1文字）
@override final  String firstChar;
/// 最後の文字（ひらがな1文字）
@override final  String lastChar;
/// 認識完了日時
@override@TimestampConverter() final  DateTime recognizedAt;

/// Create a copy of AIResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIResultCopyWith<_AIResult> get copyWith => __$AIResultCopyWithImpl<_AIResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIResult&&(identical(other.word, word) || other.word == word)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.firstChar, firstChar) || other.firstChar == firstChar)&&(identical(other.lastChar, lastChar) || other.lastChar == lastChar)&&(identical(other.recognizedAt, recognizedAt) || other.recognizedAt == recognizedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,word,confidence,firstChar,lastChar,recognizedAt);

@override
String toString() {
  return 'AIResult(word: $word, confidence: $confidence, firstChar: $firstChar, lastChar: $lastChar, recognizedAt: $recognizedAt)';
}


}

/// @nodoc
abstract mixin class _$AIResultCopyWith<$Res> implements $AIResultCopyWith<$Res> {
  factory _$AIResultCopyWith(_AIResult value, $Res Function(_AIResult) _then) = __$AIResultCopyWithImpl;
@override @useResult
$Res call({
 String word, double confidence, String firstChar, String lastChar,@TimestampConverter() DateTime recognizedAt
});




}
/// @nodoc
class __$AIResultCopyWithImpl<$Res>
    implements _$AIResultCopyWith<$Res> {
  __$AIResultCopyWithImpl(this._self, this._then);

  final _AIResult _self;
  final $Res Function(_AIResult) _then;

/// Create a copy of AIResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? word = null,Object? confidence = null,Object? firstChar = null,Object? lastChar = null,Object? recognizedAt = null,}) {
  return _then(_AIResult(
word: null == word ? _self.word : word // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,firstChar: null == firstChar ? _self.firstChar : firstChar // ignore: cast_nullable_to_non_nullable
as String,lastChar: null == lastChar ? _self.lastChar : lastChar // ignore: cast_nullable_to_non_nullable
as String,recognizedAt: null == recognizedAt ? _self.recognizedAt : recognizedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
