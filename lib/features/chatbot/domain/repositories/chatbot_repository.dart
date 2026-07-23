import 'package:dartz/dartz.dart';
import 'package:citapps/core/errors/failures.dart';
import 'package:citapps/features/chatbot/domain/entities/chat_message.dart';

/// Contrato abstracto para el repositorio de Chatbot (Repository Pattern).
abstract class ChatbotRepository {
  /// Envía la conversación acumulada y la nueva pregunta al bot
  /// y devuelve el mensaje de respuesta emitido por la IA o una falla [Failure].
  Future<Either<Failure, ChatMessage>> sendMessage({
    required List<ChatMessage> history,
    required String message,
  });
}
