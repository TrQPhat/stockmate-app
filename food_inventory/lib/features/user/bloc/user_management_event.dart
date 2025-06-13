part of 'user_management_bloc.dart';

abstract class UserManagementEvent extends Equatable {
  const UserManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadStorageMembers extends UserManagementEvent {
  final String storageId;

  const LoadStorageMembers(this.storageId);

  @override
  List<Object> get props => [storageId];
}

class InviteUserToStorage extends UserManagementEvent {
  final String storageId;
  final String email;
  final MemberRole role;

  const InviteUserToStorage({
    required this.storageId,
    required this.email,
    required this.role,
  });

  @override
  List<Object> get props => [storageId, email, role];
}

class UpdateMemberRole extends UserManagementEvent {
  final String storageId;
  final String memberId;
  final MemberRole role;

  const UpdateMemberRole({
    required this.storageId,
    required this.memberId,
    required this.role,
  });

  @override
  List<Object> get props => [storageId, memberId, role];
}

class RemoveMemberFromStorage extends UserManagementEvent {
  final String storageId;
  final String memberId;

  const RemoveMemberFromStorage({
    required this.storageId,
    required this.memberId,
  });

  @override
  List<Object> get props => [storageId, memberId];
}

class GetStorageInviteCode extends UserManagementEvent {
  final String storageId;

  const GetStorageInviteCode(this.storageId);

  @override
  List<Object> get props => [storageId];
}

class GenerateNewInviteCode extends UserManagementEvent {
  final String storageId;

  const GenerateNewInviteCode(this.storageId);

  @override
  List<Object> get props => [storageId];
}
