import 'package:ai_assistant/model/chat_message.dart';
import 'package:flutter/foundation.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool get isTyping => _isTyping;

  ChatProvider() {
    _messages.add(
      ChatMessage(
        id: 'welcome',
        text: "Hey! 🤖 I'm your AI assistant. Ask me anything,",
        isUser: false,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();

    if (trimmed.isEmpty || _isTyping) return;

    _messages.add(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: trimmed,
        isUser: true,
        createdAt: DateTime.now(),
      ),
    );

    _isTyping = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(microseconds: 700));

    _messages.add(
      ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text:
            'I received your message: "$trimmed"\n\n'
            'My real AI connection is coming next!',
        isUser: false,
        createdAt: DateTime.now(),
      ),
    );

    _isTyping = false;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _isTyping = false;
    notifyListeners();
  }
}
