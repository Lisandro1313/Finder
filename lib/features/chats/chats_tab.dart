import 'package:flutter/material.dart';

import '../../data/models/match_item.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../chat/chat_screen.dart';
import '../common/display_name.dart';
import '../common/empty_state_panel.dart';
import '../common/identity_avatar.dart';
import '../common/time_ago.dart';
import '../common/ui_feedback.dart';

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
          return const EmptyStatePanel(
            icon: Icons.chat_bubble_outline,
            title: 'Cuando hagas match, charlamos',
            subtitle: 'Tus conversaciones van a aparecer aca para seguir conectando.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            final otherId = match.otherUser(currentUserId);
            final otherName = displayNameFromId(otherId);
            final timeAgo = formatTimeAgo(match.updatedAt);
            final sentByMe = match.lastSenderId == currentUserId;
            final avatarHeroTag = 'chat_avatar_$otherId';

            return TweenAnimationBuilder<double>(
              key: ValueKey(match.id),
              duration: Duration(milliseconds: 220 + (index * 35)),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  leading: IdentityAvatar(
                    seed: otherId,
                    label: otherName,
                    heroTag: avatarHeroTag,
                  ),
                  title: Text(otherName),
                  subtitle: Text(
                    '${sentByMe ? 'Tu: ' : ''}${match.lastMessage}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(timeAgo, style: theme.textTheme.bodySmall),
                  onTap: () {
                    UiFeedback.selection();
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 280),
                        reverseTransitionDuration: const Duration(milliseconds: 220),
                        pageBuilder: (_, __, ___) => ChatScreen(
                          matchId: match.id,
                          currentUserId: currentUserId,
                          chatRepository: chatRepository,
                          chatTitle: otherName,
                          avatarSeed: otherId,
                          avatarLabel: otherName,
                          avatarHeroTag: avatarHeroTag,
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0.02, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(position: slide, child: child),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
