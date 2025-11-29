// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Submission _$SubmissionFromJson(Map<String, dynamic> json) => _Submission(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      sequenceNumber: (json['sequenceNumber'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      storagePath: json['storagePath'] as String,
      status: $enumDecode(_$SubmissionStatusEnumMap, json['status']),
      aiResult: json['aiResult'] == null
          ? null
          : AIResult.fromJson(json['aiResult'] as Map<String, dynamic>),
      validation: json['validation'] == null
          ? null
          : Validation.fromJson(json['validation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SubmissionToJson(_Submission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'sequenceNumber': instance.sequenceNumber,
      'imageUrl': instance.imageUrl,
      'storagePath': instance.storagePath,
      'status': _$SubmissionStatusEnumMap[instance.status]!,
      'aiResult': instance.aiResult,
      'validation': instance.validation,
    };

const _$SubmissionStatusEnumMap = {
  SubmissionStatus.processing: 'processing',
  SubmissionStatus.completed: 'completed',
  SubmissionStatus.failed: 'failed',
};
