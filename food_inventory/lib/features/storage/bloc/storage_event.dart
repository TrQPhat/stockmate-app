part of 'storage_bloc.dart';

abstract class StorageEvent extends Equatable {
  const StorageEvent();

  @override
  List<Object> get props => [];
}

class StorageLoadRequested extends StorageEvent {}

class StorageCreateRequested extends StorageEvent {
  final String name;

  const StorageCreateRequested(this.name);

  @override
  List<Object> get props => [name];
}

class StorageJoinRequested extends StorageEvent {
  final String inviteCode;

  const StorageJoinRequested(this.inviteCode);

  @override
  List<Object> get props => [inviteCode];
}
