import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/storage.dart';

part 'storage_model.g.dart';

@JsonSerializable()
class StorageModel extends Storage {
  const StorageModel({
    required super.id,
    required super.name,
    required super.ownerId,
    required super.createdAt,
    super.memberCount,
    super.productCount,
  });

  factory StorageModel.fromJson(Map<String, dynamic> json) =>
      _$StorageModelFromJson(json);

  Map<String, dynamic> toJson() => _$StorageModelToJson(this);
}
