import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_mate/models/user_tam.dart';
import 'package:stock_mate/repositories/user_management_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserMemberRepository _repository;

  UserBloc(this._repository) : super(UserManagementInitial()) {
    on<LoadStorageMembers>(_onLoadStorageMembers);
    on<InviteUserToStorage>(_onInviteUserToStorage);
    on<UpdateMemberRole>(_onUpdateMemberRole);
    on<RemoveMemberFromStorage>(_onRemoveMemberFromStorage);
    on<GetStorageInviteCode>(_onGetStorageInviteCode);
    on<GenerateNewInviteCode>(_onGenerateNewInviteCode);
  }

  Future<void> _onLoadStorageMembers(
    LoadStorageMembers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserManagementLoading());

    try {
      final members = await _repository.getStorageMembers(event.storageId);
      emit(StorageMembersLoaded(members));
    } catch (e) {
      emit(UserManagementError(e.toString()));
    }
  }

  Future<void> _onInviteUserToStorage(
    InviteUserToStorage event,
    Emitter<UserState> emit,
  ) async {
    emit(UserManagementLoading());

    try {
      final newMember = await _repository.inviteUserToStorage(
        event.storageId,
        event.email,
        event.role,
      );

      if (state is StorageMembersLoaded) {
        final currentState = state as StorageMembersLoaded;
        final updatedMembers = List<UserMember>.from(currentState.members)
          ..add(newMember);
        emit(StorageMembersLoaded(updatedMembers));
      } else {
        final members = await _repository.getStorageMembers(event.storageId);
        emit(StorageMembersLoaded(members));
      }
    } catch (e) {
      emit(UserManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateMemberRole(
    UpdateMemberRole event,
    Emitter<UserState> emit,
  ) async {
    emit(UserManagementLoading());

    try {
      final updatedMember = await _repository.updateMemberRole(
        event.storageId,
        event.memberId,
        event.role,
      );

      if (state is StorageMembersLoaded) {
        final currentState = state as StorageMembersLoaded;
        final updatedMembers = currentState.members.map((member) {
          return member.id == updatedMember.id ? updatedMember : member;
        }).toList();
        emit(StorageMembersLoaded(updatedMembers));
      }
    } catch (e) {
      emit(UserManagementError(e.toString()));
    }
  }

  Future<void> _onRemoveMemberFromStorage(
    RemoveMemberFromStorage event,
    Emitter<UserState> emit,
  ) async {
    emit(UserManagementLoading());

    try {
      await _repository.removeMemberFromStorage(
        event.storageId,
        event.memberId,
      );

      if (state is StorageMembersLoaded) {
        final currentState = state as StorageMembersLoaded;
        final updatedMembers = currentState.members
            .where((member) => member.id != event.memberId)
            .toList();
        emit(StorageMembersLoaded(updatedMembers));
      }
    } catch (e) {
      emit(UserManagementError(e.toString()));
    }
  }

  Future<void> _onGetStorageInviteCode(
    GetStorageInviteCode event,
    Emitter<UserState> emit,
  ) async {
    emit(UserManagementLoading());

    try {
      final inviteCode =
          await _repository.getStorageInviteCode(event.storageId);
      emit(InviteCodeLoaded(inviteCode));
    } catch (e) {
      emit(UserManagementError(e.toString()));
    }
  }

  Future<void> _onGenerateNewInviteCode(
    GenerateNewInviteCode event,
    Emitter<UserState> emit,
  ) async {
    emit(UserManagementLoading());

    try {
      final newInviteCode =
          await _repository.generateNewInviteCode(event.storageId);
      emit(InviteCodeLoaded(newInviteCode));
    } catch (e) {
      emit(UserManagementError(e.toString()));
    }
  }
}
