// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'validation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Validation {

/// しりとりとして正しいか
 bool get isValid;/// 採用されたか
 bool get isAdopted;/// ゴール到達か
 bool get isGoalReached;/// 検証完了日時
@TimestampConverter() DateTime get validatedAt;/// 不採用/不正解理由のコード値
 ReasonCode? get reasonCode;/// 不採用/不正解の理由
 String? get reason;/// 採用順序（1始まり）
 int? get adoptionOrder;
/// Create a copy of Validation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationCopyWith<Validation> get copyWith => _$ValidationCopyWithImpl<Validation>(this as Validation, _$identity);

  /// Serializes this Validation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Validation&&(identical(other.isValid, isValid) || other.isValid == isValid)&&(identical(other.isAdopted, isAdopted) || other.isAdopted == isAdopted)&&(identical(other.isGoalReached, isGoalReached) || other.isGoalReached == isGoalReached)&&(identical(other.validatedAt, validatedAt) || other.validatedAt == validatedAt)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.adoptionOrder, adoptionOrder) || other.adoptionOrder == adoptionOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,isAdopted,isGoalReached,validatedAt,reasonCode,reason,adoptionOrder);

@override
String toString() {
  return 'Validation(isValid: $isValid, isAdopted: $isAdopted, isGoalReached: $isGoalReached, validatedAt: $validatedAt, reasonCode: $reasonCode, reason: $reason, adoptionOrder: $adoptionOrder)';
}


}

/// @nodoc
abstract mixin class $ValidationCopyWith<$Res>  {
  factory $ValidationCopyWith(Validation value, $Res Function(Validation) _then) = _$ValidationCopyWithImpl;
@useResult
$Res call({
 bool isValid, bool isAdopted, bool isGoalReached,@TimestampConverter() DateTime validatedAt, ReasonCode? reasonCode, String? reason, int? adoptionOrder
});




}
/// @nodoc
class _$ValidationCopyWithImpl<$Res>
    implements $ValidationCopyWith<$Res> {
  _$ValidationCopyWithImpl(this._self, this._then);

  final Validation _self;
  final $Res Function(Validation) _then;

/// Create a copy of Validation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isValid = null,Object? isAdopted = null,Object? isGoalReached = null,Object? validatedAt = null,Object? reasonCode = freezed,Object? reason = freezed,Object? adoptionOrder = freezed,}) {
  return _then(_self.copyWith(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,isAdopted: null == isAdopted ? _self.isAdopted : isAdopted // ignore: cast_nullable_to_non_nullable
as bool,isGoalReached: null == isGoalReached ? _self.isGoalReached : isGoalReached // ignore: cast_nullable_to_non_nullable
as bool,validatedAt: null == validatedAt ? _self.validatedAt : validatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reasonCode: freezed == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as ReasonCode?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,adoptionOrder: freezed == adoptionOrder ? _self.adoptionOrder : adoptionOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Validation].
extension ValidationPatterns on Validation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Validation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Validation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Validation value)  $default,){
final _that = this;
switch (_that) {
case _Validation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Validation value)?  $default,){
final _that = this;
switch (_that) {
case _Validation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isValid,  bool isAdopted,  bool isGoalReached, @TimestampConverter()  DateTime validatedAt,  ReasonCode? reasonCode,  String? reason,  int? adoptionOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Validation() when $default != null:
return $default(_that.isValid,_that.isAdopted,_that.isGoalReached,_that.validatedAt,_that.reasonCode,_that.reason,_that.adoptionOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isValid,  bool isAdopted,  bool isGoalReached, @TimestampConverter()  DateTime validatedAt,  ReasonCode? reasonCode,  String? reason,  int? adoptionOrder)  $default,) {final _that = this;
switch (_that) {
case _Validation():
return $default(_that.isValid,_that.isAdopted,_that.isGoalReached,_that.validatedAt,_that.reasonCode,_that.reason,_that.adoptionOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isValid,  bool isAdopted,  bool isGoalReached, @TimestampConverter()  DateTime validatedAt,  ReasonCode? reasonCode,  String? reason,  int? adoptionOrder)?  $default,) {final _that = this;
switch (_that) {
case _Validation() when $default != null:
return $default(_that.isValid,_that.isAdopted,_that.isGoalReached,_that.validatedAt,_that.reasonCode,_that.reason,_that.adoptionOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Validation extends Validation {
  const _Validation({required this.isValid, required this.isAdopted, required this.isGoalReached, @TimestampConverter() required this.validatedAt, this.reasonCode, this.reason, this.adoptionOrder}): super._();
  factory _Validation.fromJson(Map<String, dynamic> json) => _$ValidationFromJson(json);

/// しりとりとして正しいか
@override final  bool isValid;
/// 採用されたか
@override final  bool isAdopted;
/// ゴール到達か
@override final  bool isGoalReached;
/// 検証完了日時
@override@TimestampConverter() final  DateTime validatedAt;
/// 不採用/不正解理由のコード値
@override final  ReasonCode? reasonCode;
/// 不採用/不正解の理由
@override final  String? reason;
/// 採用順序（1始まり）
@override final  int? adoptionOrder;

/// Create a copy of Validation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationCopyWith<_Validation> get copyWith => __$ValidationCopyWithImpl<_Validation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ValidationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Validation&&(identical(other.isValid, isValid) || other.isValid == isValid)&&(identical(other.isAdopted, isAdopted) || other.isAdopted == isAdopted)&&(identical(other.isGoalReached, isGoalReached) || other.isGoalReached == isGoalReached)&&(identical(other.validatedAt, validatedAt) || other.validatedAt == validatedAt)&&(identical(other.reasonCode, reasonCode) || other.reasonCode == reasonCode)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.adoptionOrder, adoptionOrder) || other.adoptionOrder == adoptionOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,isAdopted,isGoalReached,validatedAt,reasonCode,reason,adoptionOrder);

@override
String toString() {
  return 'Validation(isValid: $isValid, isAdopted: $isAdopted, isGoalReached: $isGoalReached, validatedAt: $validatedAt, reasonCode: $reasonCode, reason: $reason, adoptionOrder: $adoptionOrder)';
}


}

/// @nodoc
abstract mixin class _$ValidationCopyWith<$Res> implements $ValidationCopyWith<$Res> {
  factory _$ValidationCopyWith(_Validation value, $Res Function(_Validation) _then) = __$ValidationCopyWithImpl;
@override @useResult
$Res call({
 bool isValid, bool isAdopted, bool isGoalReached,@TimestampConverter() DateTime validatedAt, ReasonCode? reasonCode, String? reason, int? adoptionOrder
});




}
/// @nodoc
class __$ValidationCopyWithImpl<$Res>
    implements _$ValidationCopyWith<$Res> {
  __$ValidationCopyWithImpl(this._self, this._then);

  final _Validation _self;
  final $Res Function(_Validation) _then;

/// Create a copy of Validation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isValid = null,Object? isAdopted = null,Object? isGoalReached = null,Object? validatedAt = null,Object? reasonCode = freezed,Object? reason = freezed,Object? adoptionOrder = freezed,}) {
  return _then(_Validation(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,isAdopted: null == isAdopted ? _self.isAdopted : isAdopted // ignore: cast_nullable_to_non_nullable
as bool,isGoalReached: null == isGoalReached ? _self.isGoalReached : isGoalReached // ignore: cast_nullable_to_non_nullable
as bool,validatedAt: null == validatedAt ? _self.validatedAt : validatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,reasonCode: freezed == reasonCode ? _self.reasonCode : reasonCode // ignore: cast_nullable_to_non_nullable
as ReasonCode?,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,adoptionOrder: freezed == adoptionOrder ? _self.adoptionOrder : adoptionOrder // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
