import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_mate/models/message.dart';
import 'package:stock_mate/repositories/message_reporitory.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository repository;

  MessageBloc(this.repository) : super(MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<RefreshMessages>(_onRefreshMessages);
    on<AddMessage>(_onAddMessage);
    on<DeleteMessage>(_onDeleteMessage);
    on<MessageRealtimeInserted>(_onMessageRealtimeInserted);
    on<MessageRealtimeUpdated>(_onMessageRealtimeUpdated);
    on<MessageRealtimeDeleted>(_onMessageRealtimeDeleted);
  }

  Future<void> _onLoadMessages(
      LoadMessages event, Emitter<MessageState> emit) async {
    emit(MessageLoading());
    try {
      final messages = await repository.getMessages(event.conversationId);
      emit(MessageLoaded(messages));
    } catch (e) {
      print(e.toString());
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onRefreshMessages(
      RefreshMessages event, Emitter<MessageState> emit) async {
    try {
      final messages = await repository.getMessages(event.conversationId);
      emit(MessageLoaded(messages));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onMessageRealtimeInserted(
      MessageRealtimeInserted event, Emitter<MessageState> emit) async {
    if (state is MessageLoaded) {
      final currentMessages =
          List<Message>.from((state as MessageLoaded).messages);
      currentMessages.insert(0, event.newMessage);
      //current.sort((a, b) => b.dateCreate.compareTo(a.dateCreate)); // nếu cần
      emit(MessageLoaded(currentMessages));
    }
  }

  Future<void> _onMessageRealtimeUpdated(
      MessageRealtimeUpdated event, Emitter<MessageState> emit) async {
    if (state is MessageLoaded) {
      final current = List<Message>.from(
          (state as MessageLoaded).messages); // Tạo bản sao danh sách hiện tại
      final index = current.indexWhere(
          (m) => m.id == event.oldMessage.id); // Tìm vị trí của tin nhắn cũ
      if (index != -1) {
        // Nếu tìm thấy tin nhắn cũ
        current[index] =
            event.newMessage; // Cập nhật tin nhắn cũ bằng tin nhắn mới
        emit(MessageLoaded(
            current)); // Phát ra trạng thái mới với danh sách đã cập nhật
      }
    }
  }

  Future<void> _onMessageRealtimeDeleted(
      MessageRealtimeDeleted event, Emitter<MessageState> emit) async {
    if (state is MessageLoaded) {
      final current = List<Message>.from((state as MessageLoaded).messages)
        ..removeWhere((m) => m.id == event.messageId);
      emit(MessageLoaded(current));
    }
  }

  FutureOr<void> _onAddMessage(
      AddMessage event, Emitter<MessageState> emit) async {
    //Thêm tin nhắn vào database
    final insertedMessage = await repository.insertMessages(event.newMessage);

    // Thêm tin nhắn mới vào danh sách hiện tại
    if (insertedMessage != null && state is MessageLoaded) {
      final currentMessages =
          List<Message>.from((state as MessageLoaded).messages);
      currentMessages.insert(0, insertedMessage);
      //currentMessages.sort((a, b) => b.dateCreate.compareTo(a.dateCreate)); // nếu cần
      emit(MessageLoaded(currentMessages));
    }
  }

  FutureOr<void> _onDeleteMessage(
      DeleteMessage event, Emitter<MessageState> emit) {}
}
