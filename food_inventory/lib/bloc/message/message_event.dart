import 'package:equatable/equatable.dart';
import 'package:stock_mate/models/message.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends MessageEvent {
  final int conversationId;
  const LoadMessages({required this.conversationId});
  @override
  List<Object?> get props => [conversationId];
}

class RefreshMessages extends MessageEvent {
  final int conversationId;
  const RefreshMessages({required this.conversationId});
  @override
  List<Object?> get props => [conversationId];
}

class AddMessage extends MessageEvent {
  final Message newMessage;

  const AddMessage(this.newMessage);

  @override
  List<Object?> get props => [newMessage];
}

class DeleteMessage extends MessageEvent {
  final String id;

  const DeleteMessage(this.id);

  @override
  List<Object?> get props => [id];
}

class MessageRealtimeInserted extends MessageEvent {
  final Message newMessage;

  const MessageRealtimeInserted(this.newMessage);

  @override
  List<Object?> get props => [newMessage];
}

class MessageRealtimeUpdated extends MessageEvent {
  final Message oldMessage;
  final Message newMessage;

  const MessageRealtimeUpdated(
      {required this.oldMessage, required this.newMessage});

  @override
  List<Object?> get props => [oldMessage, newMessage];
}

class MessageRealtimeDeleted extends MessageEvent {
  final String messageId;

  const MessageRealtimeDeleted(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
