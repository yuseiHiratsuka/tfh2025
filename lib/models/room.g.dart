// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Room _$RoomFromJson(Map<String, dynamic> json) => _Room(
  id: json['id'] as String,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  status: $enumDecode(_$RoomStatusEnumMap, json['status']),
  startCharacter: json['startCharacter'] as String,
  goalCharacter: json['goalCharacter'] as String,
  maxPlayers: (json['maxPlayers'] as num).toInt(),
  timeLimit: (json['timeLimit'] as num).toInt(),
  currentCharacter: json['currentCharacter'] as String,
  currentSequence: (json['currentSequence'] as num).toInt(),
  usedWords: (json['usedWords'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  chainCount: (json['chainCount'] as num).toInt(),
  isGoalReached: json['isGoalReached'] as bool,
  totalSubmissions: (json['totalSubmissions'] as num).toInt(),
  totalParticipants: (json['totalParticipants'] as num).toInt(),
  failureReason: $enumDecodeNullable(
    _$FailureReasonEnumMap,
    json['failureReason'],
  ),
  startedAt: const TimestampConverter().fromJson(json['startedAt']),
  goalReachedBy: json['goalReachedBy'] as String?,
  finishedAt: const TimestampConverter().fromJson(json['finishedAt']),
  score: (json['score'] as num?)?.toInt(),
  timeBonus: (json['timeBonus'] as num?)?.toInt(),
  chainBonus: (json['chainBonus'] as num?)?.toInt(),
);

Map<String, dynamic> _$RoomToJson(_Room instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'status': _$RoomStatusEnumMap[instance.status]!,
  'startCharacter': instance.startCharacter,
  'goalCharacter': instance.goalCharacter,
  'maxPlayers': instance.maxPlayers,
  'timeLimit': instance.timeLimit,
  'currentCharacter': instance.currentCharacter,
  'currentSequence': instance.currentSequence,
  'usedWords': instance.usedWords,
  'chainCount': instance.chainCount,
  'isGoalReached': instance.isGoalReached,
  'totalSubmissions': instance.totalSubmissions,
  'totalParticipants': instance.totalParticipants,
  'failureReason': _$FailureReasonEnumMap[instance.failureReason],
  'startedAt': _$JsonConverterToJson<dynamic, DateTime>(
    instance.startedAt,
    const TimestampConverter().toJson,
  ),
  'goalReachedBy': instance.goalReachedBy,
  'finishedAt': _$JsonConverterToJson<dynamic, DateTime>(
    instance.finishedAt,
    const TimestampConverter().toJson,
  ),
  'score': instance.score,
  'timeBonus': instance.timeBonus,
  'chainBonus': instance.chainBonus,
};

const _$RoomStatusEnumMap = {
  RoomStatus.waiting: 'waiting',
  RoomStatus.playing: 'playing',
  RoomStatus.success: 'success',
  RoomStatus.failed: 'failed',
};

const _$FailureReasonEnumMap = {
  FailureReason.timeout: 'timeout',
  FailureReason.maxTurns: 'maxTurns',
  FailureReason.giveup: 'giveup',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
