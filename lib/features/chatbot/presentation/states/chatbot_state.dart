import 'package:equatable/equatable.dart';
import 'package:citapps/features/chatbot/domain/entities/chat_message.dart';

class ChatbotState extends Equatable {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? errorMessage;

  const ChatbotState({
    this.messages = const [],
    this.isSending = false,
    this.errorMessage,
  });

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? errorMessage,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isSending, errorMessage];
}
