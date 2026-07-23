import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:citapps/core/errors/exceptions.dart';
import 'package:citapps/features/chatbot/data/models/chat_message_model.dart';
import 'package:citapps/features/chatbot/domain/entities/chat_message.dart';

abstract class ChatbotRemoteDataSource {
  Future<ChatMessageModel> sendMessage({
    required List<ChatMessage> history,
    required String message,
  });
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final SupabaseClient supabaseClient;

  ChatbotRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<ChatMessageModel> sendMessage({
    required List<ChatMessage> history,
    required String message,
  }) async {
    try {
      // 1. Convertir el historial al formato esperado por la Edge Function
      final formattedHistory = history.map((msg) {
        return ChatMessageModel.fromEntity(msg).toJson();
      }).toList();

      // 2. Agregar el nuevo mensaje del usuario
      formattedHistory.add({
        'role': 'user',
        'content': message,
      });

      // 3. Invocar la Edge Function de Supabase 'chat'
      final response = await supabaseClient.functions.invoke(
        'chat',
        body: {
          'messages': formattedHistory,
        },
      );

      // Log de diagnóstico en consola de Flutter
      // ignore: avoid_print
      print('=== CHATBOT RESPONSE === Status: ${response.status}, Data: ${response.data}');

      final data = response.data;
      if (data is Map && data.containsKey('error')) {
        throw ServerException(message: data['error'] as String);
      }

      if (response.status != 200) {
        final errorMsg = (data is Map && data.containsKey('error'))
            ? data['error'] as String
            : 'Error en el servidor de IA (${response.status})';
        throw ServerException(message: errorMsg, statusCode: response.status);
      }

      if (data == null || data is! Map || !data.containsKey('reply')) {
        throw const ServerException(message: 'Respuesta inválida del servidor de IA');
      }

      final replyText = data['reply'] as String;

      return ChatMessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: MessageSender.bot,
        text: replyText,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );
    } on FunctionException catch (e) {
      throw ServerException(message: e.reasonPhrase ?? 'Error invocando la Edge Function de Supabase');
    } on SocketException {
      throw const NetworkException();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
