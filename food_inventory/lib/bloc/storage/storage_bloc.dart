import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_mate/models/storage.dart';
import 'package:stock_mate/repositories/storage_repository.dart';

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

      emit(StorageSuccess(storage: newStorage));
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
      final storage = await _storageRepository.joinStorageByKey(
        key: event.inviteCode,
      );

      emit(StorageSuccess(storage: storage));
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }
}
