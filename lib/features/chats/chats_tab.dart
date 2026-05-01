import 'package:flutter/material.dart';

import '../../data/models/match_item.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../chat/chat_screen.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({
    super.key,
    required this.currentUserId,
    required this.matchRepository,
    required this.chatRepository,
  });

  final String currentUserId;
  final MatchRepository matchRepository;
  final ChatRepository chatRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MatchItem>>(
      stream: matchRepository.watchMatches(currentUserId),
      builder: (context, snapshot) {
        final matches = snapshot.data ?? const [];
        if (matches.isEmpty) {
          return const Center(child: Text('Aun no tienes chats activos.'));
        }

        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.chat_bubble_outline)),
              title: Text('Chat con ${match.otherUser(currentUserId)}'),
              subtitle: Text(match.lastMessage),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      matchId: match.id,
                      currentUserId: currentUserId,
                      chatRepository: chatRepository,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
