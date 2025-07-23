part of 'storage_bloc.dart';

abstract class StorageState extends Equatable {
  const StorageState();

  @override
  List<Object> get props => [];
}

class StorageInitial extends StorageState {}

class StorageLoading extends StorageState {}

class StorageSuccess extends StorageState {
  final Storage storage;
  const StorageSuccess({required this.storage});

  @override
  List<Object> get props => [storage];
}

class StorageLoaded extends StorageState {
  final List<Storage> storages;
  const StorageLoaded({required this.storages});

  @override
  List<Object> get props => [storages];
}

class StorageError extends StorageState {
  final String message;

  const StorageError(this.message);

  @override
  List<Object> get props => [message];
}

class StorageMembersLoaded extends StorageState {
  final List<User> members;

  const StorageMembersLoaded({required this.members});

  @override
  List<Object> get props => [members];
}
