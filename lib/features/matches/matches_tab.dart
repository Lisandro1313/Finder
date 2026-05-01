import 'package:flutter/material.dart';

import '../../data/models/match_item.dart';
import '../../data/repositories/match_repository.dart';
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
          return Center(
            child: Text(
              'Sin matches por ahora. Sigue dando likes.',
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
            final activeNow = match.updatedAt != null &&
                DateTime.now().difference(match.updatedAt!).inMinutes < 5;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                leading: Stack(
                  children: [
                    const CircleAvatar(radius: 22, child: Icon(Icons.favorite_rounded)),
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
                title: Text(otherId),
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
            );
          },
        );
      },
    );
  }
}
