// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Participant _$ParticipantFromJson(Map<String, dynamic> json) => _Participant(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      joinedAt: const TimestampConverter().fromJson(json['joinedAt']),
      avatarUrl: json['avatarUrl'] as String?,
      lastSubmittedAt:
          const TimestampConverter().fromJson(json['lastSubmittedAt']),
    );

Map<String, dynamic> _$ParticipantToJson(_Participant instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'joinedAt': const TimestampConverter().toJson(instance.joinedAt),
      'avatarUrl': instance.avatarUrl,
      'lastSubmittedAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.lastSubmittedAt, const TimestampConverter().toJson),
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
