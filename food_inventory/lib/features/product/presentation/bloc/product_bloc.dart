import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/create_product_usecase.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final CreateProductUseCase createProductUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.createProductUseCase,
  }) : super(ProductInitial()) {
    on<ProductLoadRequested>(_onProductLoadRequested);
    on<ProductCreateRequested>(_onProductCreateRequested);
  }

  void _onProductLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await getProductsUseCase(event.storageId);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void _onProductCreateRequested(
    ProductCreateRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      await createProductUseCase(event.storageId, event.data);
      add(ProductLoadRequested(event.storageId));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
