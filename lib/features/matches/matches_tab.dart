import 'package:flutter/material.dart';

import '../../data/models/match_item.dart';
import '../../data/repositories/match_repository.dart';
import '../common/display_name.dart';
import '../common/empty_state_panel.dart';
import '../common/identity_avatar.dart';
import '../common/time_ago.dart';

class MatchesTab extends StatelessWidget {
  const MatchesTab({
    super.key,
    required this.currentUserId,
    required this.matchRepository,
  });

  final String currentUserId;
  final MatchRepository matchRepository;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<MatchItem>>(
      stream: matchRepository.watchMatches(currentUserId),
      builder: (context, snapshot) {
        final matches = snapshot.data ?? const [];
        if (matches.isEmpty) {
          return const EmptyStatePanel(
            icon: Icons.favorite_outline,
            title: 'Tu proximo match esta cerca',
            subtitle: 'Dale like a mas perfiles para abrir nuevas conversaciones.',
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
            final activeNow = match.updatedAt != null &&
                DateTime.now().difference(match.updatedAt!).inMinutes < 5;

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
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  leading: Stack(
                    children: [
                      IdentityAvatar(seed: otherId, label: otherName, radius: 22),
                      if (activeNow)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(otherName),
                  subtitle: Text(match.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(timeAgo, style: theme.textTheme.bodySmall),
                      if (activeNow)
                        const Text(
                          'Activo',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF00A63E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
