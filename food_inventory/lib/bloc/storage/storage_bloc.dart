import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_mate/core/config/app_config.dart';
import 'package:stock_mate/core/di/injection_container.dart';
import 'package:stock_mate/models/storage.dart';
import 'package:stock_mate/models/user.dart';
import 'package:stock_mate/repositories/storage_repository.dart';

part 'storage_event.dart';
part 'storage_state.dart';

class StorageBloc extends Bloc<StorageEvent, StorageState> {
  final StorageRepository _storageRepository;
  StorageBloc(this._storageRepository) : super(StorageInitial()) {
    on<StorageLoadRequested>(_onStorageLoadRequested);
    on<StorageCreateRequested>(_onStorageCreateRequested);
    on<StorageJoinRequested>(_onStorageJoinRequested);
    on<StorageMembersRequested>(_onStorageMembersRequested);
    on<UpdateMemberRole>(_onUpdateMemberRole);
    on<RemoveMember>(_onRemoveMember);
    on<InviteMember>(_onInviteMember);
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

  Future<void> _onStorageMembersRequested(
    StorageMembersRequested event,
    Emitter<StorageState> emit,
  ) async {
    emit(StorageLoading());
    try {
      final prefs = getIt<SharedPreferences>();
      final storageId = prefs.getInt(AppConfig.storageIdKey);
      if (storageId == null) {
        emit(const StorageError("Không tìm thấy kho hàng"));
        return;
      }
      final members = await _storageRepository.getAllUsersInStorage();
      emit(StorageMembersLoaded(members: members));
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }

  Future<void> _onUpdateMemberRole(
    UpdateMemberRole event,
    Emitter<StorageState> emit,
  ) async {
    try {
      final success =
          await _storageRepository.updateMemberRole(event.userId, event.role);

      if (success) {
        final currentState = state;
        if (currentState is StorageMembersLoaded) {
          final updatedMembers = currentState.members.map((member) {
            if (member.id == event.userId) {
              // Trả về một bản sao mới của member với role mới
              return member.copyWith(role: event.role);
            }
            return member;
          }).toList();
          emit(StorageMembersLoaded(members: updatedMembers.cast<User>()));
        } else {
          emit(const StorageError(
              "Không thể cập nhật vì danh sách thành viên chưa được load"));
        }
      } else {
        emit(const StorageError("Cập nhật quyền thất bại"));
      }
    } catch (e) {
      print("here: ${e.toString()}");
      emit(StorageError(e.toString()));
    }
  }

  // Hàm handler mới cho việc xoá thành viên
  Future<void> _onRemoveMember(
    RemoveMember event,
    Emitter<StorageState> emit,
  ) async {
    try {
      // 1. Gọi đến repository để thực hiện việc xoá
      final success = await _storageRepository.removeMember(event.userId);

      if (success) {
        // 2. Nếu API trả về thành công, cập nhật lại state của BLoC
        final currentState = state;
        if (currentState is StorageMembersLoaded) {
          // 3. Tạo một danh sách mới không chứa thành viên đã bị xoá
          final updatedMembers = currentState.members
              .where((member) => member.id != event.userId)
              .toList();

          // 4. Emit state mới với danh sách đã được cập nhật
          emit(StorageMembersLoaded(members: updatedMembers));
        } else {
          // Trường hợp state hiện tại không phải là danh sách members
          emit(const StorageError(
              "Không thể xoá vì danh sách thành viên chưa được load"));
        }
      } else {
        // Nếu API trả về thất bại
        emit(const StorageError("Xoá thành viên thất bại"));
      }
    } catch (e) {
      // Bắt lỗi và emit state lỗi
      emit(StorageError(e.toString()));
    }
  }

  Future<void> _onInviteMember(
    InviteMember event,
    Emitter<StorageState> emit,
  ) async {
    try {
      emit(StorageLoading());

      // Gửi lời mời, repository trả về User mới nếu thành công
      final newUser = await _storageRepository.inviteMember(
        event.email,
        event.role,
      );

      if (newUser == null) {
        emit(const StorageError("Không thể mời thành viên mới."));
        return;
      }

      final currentState = state;

      if (currentState is StorageMembersLoaded) {
        final updatedMembers = List<User>.from(currentState.members)
          ..add(newUser);
        emit(StorageMembersLoaded(members: updatedMembers));
      } else {
        // Nếu không phải trạng thái loaded, ta load lại từ đầu
        final members = await _storageRepository.getAllUsersInStorage();
        emit(StorageMembersLoaded(members: members));
      }
    } catch (e) {
      emit(StorageError("Lỗi khi mời thành viên: ${e.toString()}"));
    }
  }
}
