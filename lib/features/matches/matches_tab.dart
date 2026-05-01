import 'package:flutter/material.dart';

import '../../data/models/match_item.dart';
import '../../data/repositories/match_repository.dart';

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
    return StreamBuilder<List<MatchItem>>(
      stream: matchRepository.watchMatches(currentUserId),
      builder: (context, snapshot) {
        final matches = snapshot.data ?? const [];
        if (matches.isEmpty) {
          return const Center(child: Text('Sin matches por ahora. Sigue dando likes.'));
        }

        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.favorite)),
              title: Text('Match con ${match.otherUser(currentUserId)}'),
              subtitle: Text(match.lastMessage),
            );
          },
        );
      },
    );
  }
}
