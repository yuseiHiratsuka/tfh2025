// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'validation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Validation _$ValidationFromJson(Map<String, dynamic> json) => _Validation(
  isValid: json['isValid'] as bool,
  isAdopted: json['isAdopted'] as bool,
  isGoalReached: json['isGoalReached'] as bool,
  validatedAt: const TimestampConverter().fromJson(json['validatedAt']),
  reasonCode: $enumDecodeNullable(_$ReasonCodeEnumMap, json['reasonCode']),
  reason: json['reason'] as String?,
  adoptionOrder: (json['adoptionOrder'] as num?)?.toInt(),
);

Map<String, dynamic> _$ValidationToJson(_Validation instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'isAdopted': instance.isAdopted,
      'isGoalReached': instance.isGoalReached,
      'validatedAt': const TimestampConverter().toJson(instance.validatedAt),
      'reasonCode': _$ReasonCodeEnumMap[instance.reasonCode],
      'reason': instance.reason,
      'adoptionOrder': instance.adoptionOrder,
    };

const _$ReasonCodeEnumMap = {
  ReasonCode.startCharMismatch: 'start_char_mismatch',
  ReasonCode.endsWithN: 'ends_with_n',
  ReasonCode.wordDuplicated: 'word_duplicated',
  ReasonCode.minTurnsNotReached: 'min_turns_not_reached',
  ReasonCode.alreadyAdvanced: 'already_advanced',
};
