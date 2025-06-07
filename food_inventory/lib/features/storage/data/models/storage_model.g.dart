// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageModel _$StorageModelFromJson(Map<String, dynamic> json) => StorageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$StorageModelToJson(StorageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerId': instance.ownerId,
      'createdAt': instance.createdAt.toIso8601String(),
      'memberCount': instance.memberCount,
      'productCount': instance.productCount,
    };
