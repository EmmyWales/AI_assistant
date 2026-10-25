import 'package:ai_assistant/providers/chat_provider.dart';
import 'package:ai_assistant/widgets/chat_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Color appBackground = Color(0xFF101313);
const Color appSurface = Color(0xFF1B2020);
const Color appGreen = Color(0xFF45D483);
const Color appMuted = Color(0xFF92999A);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty) return;
    _controller.clear();

    await context.read<ChatProvider>().sendMessage(text);

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBackground,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFF243B30),
              child: Icon(Icons.auto_awesome, color: appGreen),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Your personal AI companion',
                  style: TextStyle(fontSize: 11, color: appMuted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Clear conversation',
            onPressed: chat.isTyping
                ? null
                : () => _showClearConfirmation(context),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chat.messages.length + (chat.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chat.messages.length) {
                  return const TypingIndicator();
                }

                return MessageBubble(message: chat.messages[index]);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(
                color: appSurface,
                border: Border(top: BorderSide(color: Color(0xFF29302F))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        filled: true,
                        fillColor: const Color(0xFF252A2B),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: chat.isTyping ? null : _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: appGreen,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: appGreen.withValues(alpha: 0.35),
                    ),
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showClearConfirmation(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Clear conversation?'),
      content: const Text('This will remove all messages from this chat.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Clear'),
        ),
      ],
    ),
  );

  if (!context.mounted || confirmed != true) return;

  context.read<ChatProvider>().clearChat();
}