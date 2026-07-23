import 'package:flutter/material.dart';
import 'package:citapps/features/chatbot/presentation/widgets/chatbot_modal_sheet.dart';

class ChatbotFloatingButton extends StatelessWidget {
  final String? tooltip;
  final Object? heroTag;

  const ChatbotFloatingButton({
    super.key,
    this.tooltip = 'Consultar CitBot',
    this.heroTag = 'chatbot_fab',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      heroTag: heroTag,
      backgroundColor: theme.primaryColor,
      tooltip: tooltip,
      onPressed: () => ChatbotModalSheet.show(context),
      child: const Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
      ),
    );
  }
}

class ChatbotIconButton extends StatelessWidget {
  const ChatbotIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.smart_toy_rounded),
      tooltip: 'CitBot - Asistente IA',
      onPressed: () => ChatbotModalSheet.show(context),
    );
  }
}
