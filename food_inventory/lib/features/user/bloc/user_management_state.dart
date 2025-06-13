part of 'user_management_bloc.dart';

abstract class UserManagementState extends Equatable {
  const UserManagementState();

  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserManagementState {}

class UserManagementLoading extends UserManagementState {}

class StorageMembersLoaded extends UserManagementState {
  final List<UserMember> members;

  const StorageMembersLoaded(this.members);

  @override
  List<Object> get props => [members];
}

class InviteCodeLoaded extends UserManagementState {
  final String inviteCode;

  const InviteCodeLoaded(this.inviteCode);

  @override
  List<Object> get props => [inviteCode];
}

class UserManagementError extends UserManagementState {
  final String message;

  const UserManagementError(this.message);

  @override
  List<Object> get props => [message];
}
