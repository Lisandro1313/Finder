import 'package:flutter/material.dart';

import '../../data/models/match_item.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../chat/chat_screen.dart';
import '../common/time_ago.dart';

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
    final theme = Theme.of(context);

    return StreamBuilder<List<MatchItem>>(
      stream: matchRepository.watchMatches(currentUserId),
      builder: (context, snapshot) {
        final matches = snapshot.data ?? const [];
        if (matches.isEmpty) {
          return Center(
            child: Text(
              'Aun no tienes chats activos.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            final otherId = match.otherUser(currentUserId);
            final timeAgo = formatTimeAgo(match.updatedAt);
            final sentByMe = match.lastSenderId == currentUserId;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              leading: const CircleAvatar(child: Icon(Icons.chat_bubble_outline)),
              title: Text(otherId),
              subtitle: Text(
                '${sentByMe ? 'Tu: ' : ''}${match.lastMessage}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(timeAgo, style: theme.textTheme.bodySmall),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      matchId: match.id,
                      currentUserId: currentUserId,
                      chatRepository: chatRepository,
                      chatTitle: otherId,
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
