import 'package:citapps/features/chatbot/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.sender,
    required super.text,
    required super.timestamp,
    super.status,
  });

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      sender: entity.sender,
      text: entity.text,
      timestamp: entity.timestamp,
      status: entity.status,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final senderStr = json['role'] as String? ?? 'assistant';
    return ChatMessageModel(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sender: senderStr == 'user' ? MessageSender.user : MessageSender.bot,
      text: json['content'] as String? ?? json['text'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': sender == MessageSender.user ? 'user' : 'assistant',
      'content': text,
    };
  }
}
