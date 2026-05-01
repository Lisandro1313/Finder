import 'package:flutter/material.dart';

import '../../data/models/finder_profile.dart';

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({
    super.key,
    required this.profiles,
    required this.profileIndex,
    required this.dailyLikesLeft,
    required this.superLikesLeft,
    required this.onPass,
    required this.onLike,
    required this.onSuperLike,
    required this.onBoostTap,
    required this.onReportProfile,
    required this.onBlockProfile,
  });

  final List<FinderProfile> profiles;
  final int profileIndex;
  final int dailyLikesLeft;
  final int superLikesLeft;
  final VoidCallback onPass;
  final VoidCallback? onLike;
  final VoidCallback onSuperLike;
  final VoidCallback onBoostTap;
  final VoidCallback onReportProfile;
  final VoidCallback onBlockProfile;

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final profile = profiles[profileIndex % profiles.length];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Likes: $dailyLikesLeft | Super Likes: $superLikesLeft'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${profile.name}, ${profile.age}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('A ${profile.distanceKm} km'),
                    const SizedBox(height: 12),
                    Text(profile.bio),
                    const Spacer(),
                    const Text('MVP: swipe + likes + superlikes + chat en tiempo real.'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPass,
                  icon: const Icon(Icons.close),
                  label: const Text('Pasar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onLike,
                  icon: const Icon(Icons.favorite),
                  label: const Text('Like'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: onSuperLike,
            icon: const Icon(Icons.stars),
            label: const Text('Super Like'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: onBoostTap,
            icon: const Icon(Icons.flash_on),
            label: const Text('Boost 30 min'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReportProfile,
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Reportar perfil'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBlockProfile,
                  icon: const Icon(Icons.block),
                  label: const Text('Bloquear perfil'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
