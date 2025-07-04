import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String? id; // uuid
  final int conversationId;
  final String type; // 'text', 'image', 'file'
  final String nameSender;
  final int senderId;
  final String? content;
  final String? fileUrl;
  final String status; // 'normal', 'updated', 'deleted'
  final DateTime createdAt;

  Message({
    this.id,
    required this.conversationId,
    this.type = 'text',
    required this.nameSender,
    required this.senderId,
    this.content,
    this.fileUrl,
    this.status = 'normal',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as int,
      type: json['type'] as String? ?? 'text',
      nameSender: json['name_sender'] as String,
      senderId: json['sender_id'] as int,
      content: json['content'] as String?,
      fileUrl: json['file_url'] as String?,
      status: json['status'] as String? ?? 'normal',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'conversation_id': conversationId,
      'type': type,
      'name_sender': nameSender,
      'sender_id': senderId,
      if (content != null) 'content': content,
      if (fileUrl != null) 'file_url': fileUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    int? conversationId,
    String? type,
    String? nameSender,
    int? senderId,
    String? content,
    String? fileUrl,
    String? status,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      type: type ?? this.type,
      nameSender: nameSender ?? this.nameSender,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        type,
        nameSender,
        senderId,
        content,
        fileUrl,
        status,
        createdAt,
      ];
}
