import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:citapps/core/providers/supabase_provider.dart';
import 'package:citapps/features/chatbot/data/datasources/chatbot_remote_data_source.dart';
import 'package:citapps/features/chatbot/data/repositories/chatbot_repository_impl.dart';
import 'package:citapps/features/chatbot/domain/entities/chat_message.dart';
import 'package:citapps/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:citapps/features/chatbot/domain/usecases/send_chat_message.dart';
import 'package:citapps/features/chatbot/presentation/states/chatbot_state.dart';

// Providers de Inyección de Dependencias
final chatbotRemoteDataSourceProvider = Provider<ChatbotRemoteDataSource>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ChatbotRemoteDataSourceImpl(supabaseClient: supabaseClient);
});

final chatbotRepositoryProvider = Provider<ChatbotRepository>((ref) {
  final remoteDataSource = ref.watch(chatbotRemoteDataSourceProvider);
  return ChatbotRepositoryImpl(remoteDataSource: remoteDataSource);
});

final sendChatMessageUseCaseProvider = Provider<SendChatMessage>((ref) {
  final repository = ref.watch(chatbotRepositoryProvider);
  return SendChatMessage(repository);
});

// StateNotifier del Chatbot
class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final SendChatMessage _sendChatMessage;
  final Uuid _uuid = const Uuid();

  ChatbotNotifier(this._sendChatMessage) : super(const ChatbotState()) {
    _initWelcomeMessage();
  }

  void _initWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: _uuid.v4(),
      sender: MessageSender.bot,
      text: '¡Hola! 👋 Soy CitBot, tu asistente de CitApps.\n\n¿En qué puedo ayudarte hoy sobre la gestión de tu barbería o el uso de la aplicación?',
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [welcomeMessage]);
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || state.isSending) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      sender: MessageSender.user,
      text: trimmedText,
      timestamp: DateTime.now(),
    );

    // Actualizar UI con el mensaje del usuario e indicador de carga
    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMessage);
    state = state.copyWith(
      messages: updatedMessages,
      isSending: true,
      errorMessage: null,
    );

    // Filtrar historial existente (solo mensajes enviados con éxito)
    final history = updatedMessages
        .where((m) => m.status == MessageStatus.sent)
        .toList();

    final result = await _sendChatMessage(
      SendChatMessageParams(
        history: history,
        message: trimmedText,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isSending: false,
          errorMessage: failure.message,
        );
      },
      (botMessage) {
        final newMessagesList = List<ChatMessage>.from(state.messages)..add(botMessage);
        state = state.copyWith(
          messages: newMessagesList,
          isSending: false,
          errorMessage: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void resetChat() {
    state = const ChatbotState();
    _initWelcomeMessage();
  }
}

// Provider principal expuesto a la UI
final chatbotNotifierProvider = StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  return ChatbotNotifier(ref.watch(sendChatMessageUseCaseProvider));
});
