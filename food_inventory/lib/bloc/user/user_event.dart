part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadStorageMembers extends UserEvent {
  final int storageId;

  const LoadStorageMembers(this.storageId);

  @override
  List<Object> get props => [storageId];
}

class InviteUserToStorage extends UserEvent {
  final int storageId;
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

class UpdateMemberRole extends UserEvent {
  final int storageId;
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

class RemoveMemberFromStorage extends UserEvent {
  final int storageId;
  final String memberId;

  const RemoveMemberFromStorage({
    required this.storageId,
    required this.memberId,
  });

  @override
  List<Object> get props => [storageId, memberId];
}

class GetStorageInviteCode extends UserEvent {
  final int storageId;

  const GetStorageInviteCode(this.storageId);

  @override
  List<Object> get props => [storageId];
}

class GenerateNewInviteCode extends UserEvent {
  final int storageId;

  const GenerateNewInviteCode(this.storageId);

  @override
  List<Object> get props => [storageId];
}
