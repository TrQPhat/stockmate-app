// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String,
      storageId: json['storageId'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unit: json['unit'] as String?,
      importDate: json['importDate'] == null
          ? null
          : DateTime.parse(json['importDate'] as String),
      expireDate: json['expireDate'] == null
          ? null
          : DateTime.parse(json['expireDate'] as String),
      note: json['note'] as String?,
      status: $enumDecodeNullable(_$ProductStatusEnumMap, json['status']) ??
          ProductStatus.conDung,
      imagePath: json['imagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storageId': instance.storageId,
      'name': instance.name,
      'category': instance.category,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'importDate': instance.importDate?.toIso8601String(),
      'expireDate': instance.expireDate?.toIso8601String(),
      'note': instance.note,
      'status': _$ProductStatusEnumMap[instance.status]!,
      'imagePath': instance.imagePath,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ProductStatusEnumMap = {
  ProductStatus.conDung: 'conDung',
  ProductStatus.hetHan: 'hetHan',
  ProductStatus.daDung: 'daDung',
  ProductStatus.huy: 'huy',
};
