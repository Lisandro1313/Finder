import 'package:flutter/material.dart';

import '../../data/models/finder_profile.dart';
import '../../data/models/user_preferences.dart';

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
    required this.preferences,
    required this.quickFilterKey,
    required this.onSelectQuickFilter,
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
  final UserPreferences preferences;
  final String quickFilterKey;
  final ValueChanged<String> onSelectQuickFilter;

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
              child: Text(
                'Likes: $dailyLikesLeft | Super Likes: $superLikesLeft\n'
                'Filtro: ${preferences.minAge}-${preferences.maxAge} anos, hasta ${preferences.maxDistanceKm} km',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: quickFilterKey == 'all',
                onSelected: (_) => onSelectQuickFilter('all'),
              ),
              ChoiceChip(
                label: const Text('Cerca'),
                selected: quickFilterKey == 'nearby',
                onSelected: (_) => onSelectQuickFilter('nearby'),
              ),
              ChoiceChip(
                label: const Text('18-25'),
                selected: quickFilterKey == '18_25',
                onSelected: (_) => onSelectQuickFilter('18_25'),
              ),
              ChoiceChip(
                label: const Text('25-35'),
                selected: quickFilterKey == '25_35',
                onSelected: (_) => onSelectQuickFilter('25_35'),
              ),
            ],
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
