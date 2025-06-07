part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class ProductLoadRequested extends ProductEvent {
  final String storageId;

  const ProductLoadRequested(this.storageId);

  @override
  List<Object> get props => [storageId];
}

class ProductCreateRequested extends ProductEvent {
  final String storageId;
  final Map<String, dynamic> data;

  const ProductCreateRequested(this.storageId, this.data);

  @override
  List<Object> get props => [storageId, data];
}
