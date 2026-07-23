import 'package:equatable/equatable.dart';

enum MessageSender { user, bot }
enum MessageStatus { sending, sent, error }

class ChatMessage extends Equatable {
  final String id;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  bool get isUser => sender == MessageSender.user;

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? text,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, sender, text, timestamp, status];
}
