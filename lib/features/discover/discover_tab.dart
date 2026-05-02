import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/finder_profile.dart';
import '../../data/models/retention_state.dart';
import '../../data/models/user_preferences.dart';
import '../common/empty_state_panel.dart';
import '../common/identity_avatar.dart';
import '../common/ui_feedback.dart';

class DiscoverTab extends StatefulWidget {
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
    required this.retentionState,
    required this.onClaimMission,
    required this.onRefreshProfiles,
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
  final RetentionState retentionState;
  final Future<void> Function(String missionId) onClaimMission;
  final Future<void> Function() onRefreshProfiles;

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  _ReactionFeedback _feedback = _ReactionFeedback.none;
  Timer? _feedbackTimer;
  double _dragDx = 0;

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.profiles.isEmpty) {
      return const EmptyStatePanel(
        icon: Icons.travel_explore_outlined,
        title: 'Cargando nuevos perfiles',
        subtitle: 'Estamos buscando gente compatible cerca tuyo.',
      );
    }

    final profile = widget.profiles[widget.profileIndex % widget.profiles.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _PillStat(label: 'Likes hoy', value: '${widget.dailyLikesLeft}'),
                      _PillStat(label: 'Super Likes', value: '${widget.superLikesLeft}'),
                      _PillStat(
                        label: 'Filtro',
                        value:
                            '${widget.preferences.minAge}-${widget.preferences.maxAge} anos | ${widget.preferences.maxDistanceKm} km',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _EarlyAccessMissionsCard(
                retentionState: widget.retentionState,
                onClaimMission: widget.onClaimMission,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _FilterChip(
                    label: 'Todos',
                    selected: widget.quickFilterKey == 'all',
                    onTap: () => widget.onSelectQuickFilter('all'),
                  ),
                  _FilterChip(
                    label: 'Cerca',
                    selected: widget.quickFilterKey == 'nearby',
                    onTap: () => widget.onSelectQuickFilter('nearby'),
                  ),
                  _FilterChip(
                    label: '18-25',
                    selected: widget.quickFilterKey == '18_25',
                    onTap: () => widget.onSelectQuickFilter('18_25'),
                  ),
                  _FilterChip(
                    label: '25-35',
                    selected: widget.quickFilterKey == '25_35',
                    onTap: () => widget.onSelectQuickFilter('25_35'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      UiFeedback.selection();
                      widget.onRefreshProfiles();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: GestureDetector(
                    key: ValueKey(profile.id),
                    onPanUpdate: (details) {
                      setState(() => _dragDx += details.delta.dx);
                    },
                    onPanEnd: (_) => _finishSwipe(),
                    onPanCancel: _resetSwipe,
                    child: Transform.translate(
                      offset: Offset(_dragDx, 0),
                      child: Transform.rotate(
                        angle: (_dragDx / 900).clamp(-0.18, 0.18),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 130,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [Color(0xFFE11D48), Color(0xFFFF8A65)],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: IdentityAvatar(
                                        seed: profile.id,
                                        label: profile.name,
                                        radius: 40,
                                        showRing: true,
                                      ),
                                    ),
                                  ],
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
                                        'Desliza: izquierda para pasar, derecha para like.',
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
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handlePass,
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Pasar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.onLike == null ? null : _handleLike,
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
                      onPressed: _handleSuperLike,
                      icon: const Icon(Icons.stars),
                      label: const Text('Super Like'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _handleBoost,
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
                      onPressed: widget.onReportProfile,
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('Reportar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onBlockProfile,
                      icon: const Icon(Icons.block),
                      label: const Text('Bloquear'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _feedback == _ReactionFeedback.none ? 0 : 1,
              child: Center(
                child: _ReactionBadge(feedback: _feedback),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _finishSwipe() {
    const threshold = 110.0;
    final dx = _dragDx;
    if (dx > threshold) {
      _handleLike();
      return;
    }
    if (dx < -threshold) {
      _handlePass();
      return;
    }
    _resetSwipe();
  }

  void _handlePass() {
    UiFeedback.selection();
    _emitFeedback(_ReactionFeedback.pass);
    _resetSwipe();
    widget.onPass();
  }

  void _handleLike() {
    if (widget.onLike == null) {
      UiFeedback.warning();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sin likes disponibles. Prueba mas tarde o usa Premium.')),
      );
      _resetSwipe();
      return;
    }
    UiFeedback.success();
    _emitFeedback(_ReactionFeedback.like);
    _resetSwipe();
    widget.onLike!.call();
  }

  void _handleSuperLike() {
    UiFeedback.emphasis();
    _emitFeedback(_ReactionFeedback.superLike);
    _resetSwipe();
    widget.onSuperLike();
  }

  void _handleBoost() {
    UiFeedback.emphasis();
    _emitFeedback(_ReactionFeedback.boost);
    _resetSwipe();
    widget.onBoostTap();
  }

  void _emitFeedback(_ReactionFeedback feedback) {
    _feedbackTimer?.cancel();
    setState(() => _feedback = feedback);
    _feedbackTimer = Timer(const Duration(milliseconds: 520), () {
      if (!mounted) return;
      setState(() => _feedback = _ReactionFeedback.none);
    });
  }

  void _resetSwipe() {
    if (!mounted) return;
    setState(() => _dragDx = 0);
  }
}

enum _ReactionFeedback { none, pass, like, superLike, boost }

class _ReactionBadge extends StatelessWidget {
  const _ReactionBadge({required this.feedback});

  final _ReactionFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final visual = _visualForFeedback(feedback);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 260),
      tween: Tween<double>(begin: 0.7, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.56),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(visual.icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              visual.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _FeedbackVisual _visualForFeedback(_ReactionFeedback value) {
    switch (value) {
      case _ReactionFeedback.pass:
        return const _FeedbackVisual(icon: Icons.close_rounded, label: 'Pasaste');
      case _ReactionFeedback.like:
        return const _FeedbackVisual(icon: Icons.favorite_rounded, label: 'Like');
      case _ReactionFeedback.superLike:
        return const _FeedbackVisual(icon: Icons.stars_rounded, label: 'Super Like');
      case _ReactionFeedback.boost:
        return const _FeedbackVisual(icon: Icons.flash_on, label: 'Boost');
      case _ReactionFeedback.none:
        return const _FeedbackVisual(icon: Icons.favorite_border, label: '');
    }
  }
}

class _FeedbackVisual {
  const _FeedbackVisual({required this.icon, required this.label});

  final IconData icon;
  final String label;
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

class _EarlyAccessMissionsCard extends StatelessWidget {
  const _EarlyAccessMissionsCard({
    required this.retentionState,
    required this.onClaimMission,
  });

  final RetentionState retentionState;
  final Future<void> Function(String missionId) onClaimMission;

  @override
  Widget build(BuildContext context) {
    final missions = retentionState.missions;
    if (missions.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Early Access: recompensas de hoy',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2EFF8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('Racha ${retentionState.streakDays}d'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Sin bots ni likes falsos: todo se desbloquea por actividad real.'),
            const SizedBox(height: 12),
            ...missions.map((mission) {
              final percent = (mission.progress / mission.target).clamp(0, 1).toDouble();
              final rewardLabel = [
                if (mission.rewardSuperLikes > 0) '+${mission.rewardSuperLikes} Super Like',
                if (mission.rewardBoosts > 0) '+${mission.rewardBoosts} Boost',
              ].join(' | ');

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F4FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mission.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(mission.description),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: percent,
                          backgroundColor: const Color(0xFFE2DDEF),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${mission.progress}/${mission.target} · Recompensa: $rewardLabel',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          if (mission.claimed)
                            const Text(
                              'Reclamada',
                              style: TextStyle(color: Color(0xFF0E9F6E), fontWeight: FontWeight.w700),
                            )
                          else
                            FilledButton.tonal(
                              onPressed: mission.completed ? () => onClaimMission(mission.id) : null,
                              child: const Text('Reclamar'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
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
