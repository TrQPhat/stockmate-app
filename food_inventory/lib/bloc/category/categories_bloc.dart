import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_mate/models/category.dart';
import 'package:stock_mate/repositories/categories_repository.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesRepository _repository;

  CategoriesBloc(this._repository) : super(CategoriesInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    try {
      final categories = await _repository.getCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      //emit(CategoriesError(e.toString()));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      if (state is CategoriesLoaded) {
        final current =
            List<Category>.from((state as CategoriesLoaded).categories);
        final newCategory = await _repository.addCategory(event.category);
        current.insert(0, newCategory);
        emit(CategoriesLoaded(current));
      } else {
        // Nếu chưa có dữ liệu, reload toàn bộ
        final categories = await _repository.getCategories();
        emit(CategoriesLoaded(categories));
      }
    } catch (e) {
      //emit(CategoriesError('Không thể thêm danh mục: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      if (state is CategoriesLoaded) {
        final current =
            List<Category>.from((state as CategoriesLoaded).categories);
        final updatedCategory =
            await _repository.updateCategory(event.category);
        final idx = current.indexWhere((c) => c.id == updatedCategory.id);
        if (idx != -1) {
          current[idx] = updatedCategory;
        }
        emit(CategoriesLoaded(current));
      } else {
        final categories = await _repository.getCategories();
        emit(CategoriesLoaded(categories));
      }
    } catch (e) {
      //emit(CategoriesError('Không thể cập nhật danh mục: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    try {
      if (state is CategoriesLoaded) {
        final current =
            List<Category>.from((state as CategoriesLoaded).categories);
        await _repository.deleteCategory(event.categoryId);
        current.removeWhere((c) => c.id == event.categoryId);
        emit(CategoriesLoaded(current));
      } else {
        final categories = await _repository.getCategories();
        emit(CategoriesLoaded(categories));
      }
    } catch (e) {
      // emit(CategoriesError('Không thể xóa danh mục: ${e.toString()}'));
    }
  }
}
