import 'package:flutter/material.dart';

import '../../data/models/chat_message.dart';
import '../../data/repositories/chat_repository.dart';
import '../common/empty_state_panel.dart';
import '../common/finder_atmosphere.dart';
import '../common/identity_avatar.dart';
import '../common/ui_feedback.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.matchId,
    required this.currentUserId,
    required this.chatRepository,
    this.chatTitle,
    this.avatarSeed,
    this.avatarLabel,
    this.avatarHeroTag,
  });

  final String matchId;
  final String currentUserId;
  final ChatRepository chatRepository;
  final String? chatTitle;
  final String? avatarSeed;
  final String? avatarLabel;
  final String? avatarHeroTag;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  static const _quickReactions = [
    '\u{1F525}',
    '\u{1F60D}',
    '\u{1F602}',
    '\u{1F440}',
    '\u{2728}',
    '\u{1F64C}',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.chatTitle ?? 'Chat';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.avatarSeed != null && widget.avatarLabel != null) ...[
              IdentityAvatar(
                seed: widget.avatarSeed!,
                label: widget.avatarLabel!,
                radius: 15,
                heroTag: widget.avatarHeroTag,
              ),
              const SizedBox(width: 10),
            ],
            Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: FinderAtmosphere(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: widget.chatRepository.watchMessages(widget.matchId),
                builder: (context, snapshot) {
                  final messages = snapshot.data ?? const [];
                  if (messages.isEmpty) {
                    return const EmptyStatePanel(
                      icon: Icons.waving_hand_outlined,
                      title: 'Rompe el hielo',
                      subtitle: 'Tu primer mensaje puede abrir una gran historia.',
                    );
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
                  child: Column(
                    children: [
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _quickReactions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final emoji = _quickReactions[index];
                            return InkWell(
                              onTap: () {
                                UiFeedback.selection();
                                _sendQuickReaction(emoji);
                              },
                              borderRadius: BorderRadius.circular(999),
                              child: Ink(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F0FA),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(emoji, style: const TextStyle(fontSize: 16)),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
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
                            onPressed: () {
                              UiFeedback.success();
                              _send();
                            },
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            child: const Icon(Icons.send_rounded),
                          ),
                        ],
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

  Future<void> _sendQuickReaction(String emoji) async {
    await widget.chatRepository.sendMessage(
      matchId: widget.matchId,
      senderId: widget.currentUserId,
      text: emoji,
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

