part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserManagementInitial extends UserState {}

class UserManagementLoading extends UserState {}

class StorageMembersLoaded extends UserState {
  final List<UserMember> members;

  const StorageMembersLoaded(this.members);

  @override
  List<Object> get props => [members];
}

class InviteCodeLoaded extends UserState {
  final String inviteCode;

  const InviteCodeLoaded(this.inviteCode);

  @override
  List<Object> get props => [inviteCode];
}

class UserManagementError extends UserState {
  final String message;

  const UserManagementError(this.message);

  @override
  List<Object> get props => [message];
}
