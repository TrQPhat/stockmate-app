import 'package:equatable/equatable.dart';

class Storage extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final DateTime createdAt;
  final int memberCount;
  final int productCount;

  const Storage({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    this.memberCount = 0,
    this.productCount = 0,
  });

  @override
  List<Object> get props => [id, name, ownerId, createdAt, memberCount, productCount];
}
