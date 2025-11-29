// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Participant _$ParticipantFromJson(Map<String, dynamic> json) => _Participant(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      joinedAt: const TimestampConverter().fromJson(json['joinedAt']),
      isReady: json['isReady'] as bool? ?? false,
      isMaster: json['isMaster'] as bool? ?? false,
      isAI: json['isAI'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String?,
      lastSubmittedAt:
          const NullableTimestampConverter().fromJson(json['lastSubmittedAt']),
    );

Map<String, dynamic> _$ParticipantToJson(_Participant instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'joinedAt': const TimestampConverter().toJson(instance.joinedAt),
      'isReady': instance.isReady,
      'isMaster': instance.isMaster,
      'isAI': instance.isAI,
      'avatarUrl': instance.avatarUrl,
      'lastSubmittedAt':
          const NullableTimestampConverter().toJson(instance.lastSubmittedAt),
    };
