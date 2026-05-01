import 'package:flutter/material.dart';

import '../../data/models/chat_message.dart';
import '../../data/repositories/chat_repository.dart';
import '../common/finder_atmosphere.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.matchId,
    required this.currentUserId,
    required this.chatRepository,
    this.chatTitle,
  });

  final String matchId;
  final String currentUserId;
  final ChatRepository chatRepository;
  final String? chatTitle;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chatTitle ?? 'Chat')),
      body: FinderAtmosphere(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: widget.chatRepository.watchMessages(widget.matchId),
                builder: (context, snapshot) {
                  final messages = snapshot.data ?? const [];
                  if (messages.isEmpty) {
                    return const Center(child: Text('Todavia no hay mensajes.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final mine = message.senderId == widget.currentUserId;
                      return Align(
                        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 320),
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: mine
                                ? Theme.of(context).colorScheme.primaryContainer
                                : const Color(0xFFF3F0FA),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(message.text),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Escribe mensaje...',
                            border: InputBorder.none,
                            filled: false,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: _send,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        child: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final text = _controller.text;
    _controller.clear();
    await widget.chatRepository.sendMessage(
      matchId: widget.matchId,
      senderId: widget.currentUserId,
      text: text,
    );
  }
}
