import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_mate/features/auth/bloc/auth_bloc.dart';
import 'package:stock_mate/features/storage/models/storage.dart';
import 'package:stock_mate/features/storage/repository/storage_repository.dart';

part 'storage_event.dart';
part 'storage_state.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final StorageRepository _storageRepository;
  StorageBloc(this._storageRepository) : super(StorageInitial()) {
    on<StorageLoadRequested>(_onStorageLoadRequested);
    on<StorageCreateRequested>(_onStorageCreateRequested);
    on<StorageJoinRequested>(_onStorageJoinRequested);
  }

  void _onStorageLoadRequested(
    StorageLoadRequested event,
    Emitter<StorageState> emit,
  ) async {
    emit(StorageLoading());
    // try {
    //   // Mock data
    //   await Future.delayed(const Duration(seconds: 1));
    //   final storages = [
    //     Storage(
    //       id: '1',
    //       name: 'Kho gia đình',
    //       ownerId: 'user1',
    //       createdAt: DateTime.now().subtract(const Duration(days: 30)),
    //     ),
    //     Storage(
    //       id: '2',
    //       name: 'Kho nhà hàng',
    //       ownerId: 'user2',
    //       createdAt: DateTime.now().subtract(const Duration(days: 15)),
    //     ),
    //   ];
    //   emit(StorageLoaded(storages));
    // } catch (e) {
    //   emit(StorageError(e.toString()));
    // }
  }

  Future<void> _onStorageCreateRequested(
    StorageCreateRequested event,
    Emitter<StorageState> emit,
  ) async {
    emit(StorageLoading());

    try {
      final newStorage = await _storageRepository.createStorage(
        name: event.name,
      );

      emit(StorageSuccess(storageId: newStorage.id));
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }

  void _onStorageJoinRequested(
    StorageJoinRequested event,
    Emitter<StorageState> emit,
  ) async {
    emit(StorageLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Join storage logic here
      add(StorageLoadRequested());
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }
}
