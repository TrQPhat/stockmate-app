import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/storage.dart';
import '../../domain/usecases/get_storages_usecase.dart';
import '../../domain/usecases/create_storage_usecase.dart';
import '../../domain/usecases/join_storage_usecase.dart';

part 'storage_event.dart';
part 'storage_state.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final GetStoragesUseCase getStoragesUseCase;
  final CreateStorageUseCase createStorageUseCase;
  final JoinStorageUseCase joinStorageUseCase;

  StorageBloc({
    required this.getStoragesUseCase,
    required this.createStorageUseCase,
    required this.joinStorageUseCase,
  }) : super(StorageInitial()) {
    on<StorageLoadRequested>(_onStorageLoadRequested);
    on<StorageCreateRequested>(_onStorageCreateRequested);
    on<StorageJoinRequested>(_onStorageJoinRequested);
  }

  void _onStorageLoadRequested(
    StorageLoadRequested event,
    Emitter<StorageState> emit,
  ) async {
    emit(StorageLoading());
    try {
      final storages = await getStoragesUseCase();
      emit(StorageLoaded(storages));
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }

  void _onStorageCreateRequested(
    StorageCreateRequested event,
    Emitter<StorageState> emit,
  ) async {
    emit(StorageLoading());
    try {
      await createStorageUseCase(event.name);
      add(StorageLoadRequested());
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
      await joinStorageUseCase(event.inviteCode);
      add(StorageLoadRequested());
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }
}
