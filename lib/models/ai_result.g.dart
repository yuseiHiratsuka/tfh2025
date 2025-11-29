// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AIResult _$AIResultFromJson(Map<String, dynamic> json) => _AIResult(
      word: json['word'] as String,
      firstChar: json['firstChar'] as String,
      lastChar: json['lastChar'] as String,
      recognizedAt: const TimestampConverter().fromJson(json['recognizedAt']),
    );

Map<String, dynamic> _$AIResultToJson(_AIResult instance) => <String, dynamic>{
      'word': instance.word,
      'firstChar': instance.firstChar,
      'lastChar': instance.lastChar,
      'recognizedAt': const TimestampConverter().toJson(instance.recognizedAt),
    };
