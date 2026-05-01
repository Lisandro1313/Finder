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
    final theme = Theme.of(context);

    if (profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text('Buscando perfiles...', style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    final profile = profiles[profileIndex % profiles.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PillStat(label: 'Likes hoy', value: '$dailyLikesLeft'),
                  _PillStat(label: 'Super Likes', value: '$superLikesLeft'),
                  _PillStat(
                    label: 'Filtro',
                    value:
                        '${preferences.minAge}-${preferences.maxAge} anos | ${preferences.maxDistanceKm} km',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _FilterChip(
                label: 'Todos',
                selected: quickFilterKey == 'all',
                onTap: () => onSelectQuickFilter('all'),
              ),
              _FilterChip(
                label: 'Cerca',
                selected: quickFilterKey == 'nearby',
                onTap: () => onSelectQuickFilter('nearby'),
              ),
              _FilterChip(
                label: '18-25',
                selected: quickFilterKey == '18_25',
                onTap: () => onSelectQuickFilter('18_25'),
              ),
              _FilterChip(
                label: '25-35',
                selected: quickFilterKey == '25_35',
                onTap: () => onSelectQuickFilter('25_35'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: Card(
                key: ValueKey(profile.id),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 130,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE11D48), Color(0xFFFF8A65)],
                        ),
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 46, color: Colors.white),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${profile.name}, ${profile.age}', style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 6),
                            Text('A ${profile.distanceKm} km', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 12),
                            Text(profile.bio, style: theme.textTheme.bodyLarge),
                            const Spacer(),
                            Text(
                              'Manten el ritmo: cuanto mas interactuas, mejores matches aparecen.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
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
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Pasar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onLike,
                  icon: const Icon(Icons.favorite_rounded),
                  label: const Text('Like'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onSuperLike,
                  icon: const Icon(Icons.stars),
                  label: const Text('Super Like'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onBoostTap,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Boost 30 min'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReportProfile,
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Reportar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBlockProfile,
                  icon: const Icon(Icons.block),
                  label: const Text('Bloquear'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillStat extends StatelessWidget {
  const _PillStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFF8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text('$label: $value'),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE11D48) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFFE11D48) : const Color(0xFFD8D3E8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF5E5576),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
