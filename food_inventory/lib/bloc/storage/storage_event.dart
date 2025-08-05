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

class StorageMembersRequested extends StorageEvent {
  const StorageMembersRequested();

  @override
  List<Object> get props => [];
}

class UpdateMemberRole extends StorageEvent {
  final int userId;
  final String role;
  const UpdateMemberRole(this.userId, this.role);

  @override
  List<Object> get props => [userId, role];
}

class RemoveMember extends StorageEvent {
  final int userId;
  const RemoveMember(this.userId);

  @override
  List<Object> get props => [userId];
}

class InviteMember extends StorageEvent {
  final String email;
  final String role;

  const InviteMember({required this.email, required this.role});

  @override
  List<Object> get props => [email, role];
}
