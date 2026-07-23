import 'package:dartz/dartz.dart';
import 'package:citapps/core/errors/failures.dart';
import 'package:citapps/features/chatbot/domain/entities/chat_message.dart';
import 'package:citapps/features/chatbot/domain/repositories/chatbot_repository.dart';

class SendChatMessageParams {
  final List<ChatMessage> history;
  final String message;

  const SendChatMessageParams({
    required this.history,
    required this.message,
  });
}

/// Caso de Uso: Enviar mensaje al chatbot de CitApps.
class SendChatMessage {
  final ChatbotRepository repository;

  SendChatMessage(this.repository);

  Future<Either<Failure, ChatMessage>> call(SendChatMessageParams params) {
    return repository.sendMessage(
      history: params.history,
      message: params.message,
    );
  }
}
