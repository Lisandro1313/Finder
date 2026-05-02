import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models/app_user.dart';
import '../data/models/finder_profile.dart';
import '../data/models/retention_state.dart';
import '../data/models/user_entitlements.dart';
import '../data/models/user_preferences.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/discover_repository.dart';
import '../data/repositories/entitlement_repository.dart';
import '../data/repositories/match_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/retention_repository.dart';
import '../data/repositories/safety_repository.dart';
import '../features/chats/chats_tab.dart';
import '../features/common/finder_atmosphere.dart';
import '../features/common/match_celebration_overlay.dart';
import '../features/common/ui_feedback.dart';
import '../features/discover/discover_tab.dart';
import '../features/matches/matches_tab.dart';
import '../features/premium/premium_tab.dart';
import '../features/profile/profile_tab.dart';
import '../services/location_service.dart';

class FinderHome extends StatefulWidget {
  const FinderHome({
    super.key,
    required this.currentUser,
    required this.discoverRepository,
    required this.matchRepository,
    required this.chatRepository,
    required this.profileRepository,
    required this.entitlementRepository,
    required this.retentionRepository,
    required this.safetyRepository,
    required this.locationService,
    required this.onLogout,
  });

  final AppUser currentUser;
  final DiscoverRepository discoverRepository;
  final MatchRepository matchRepository;
  final ChatRepository chatRepository;
  final ProfileRepository profileRepository;
  final EntitlementRepository entitlementRepository;
  final RetentionRepository retentionRepository;
  final SafetyRepository safetyRepository;
  final LocationService locationService;
  final Future<void> Function() onLogout;

  @override
  State<FinderHome> createState() => _FinderHomeState();
}

class _FinderHomeState extends State<FinderHome> {
  int _currentIndex = 0;
  int _dailyLikesLeft = 10;
  int _profileIndex = 0;
  List<FinderProfile> _profiles = const [];
  UserEntitlements _entitlements = UserEntitlements.empty;
  UserPreferences _preferences = UserPreferences.defaults;
  String _quickFilterKey = 'all';
  StreamSubscription<UserEntitlements>? _entSub;
  StreamSubscription<UserPreferences>? _prefSub;
  StreamSubscription<RetentionState>? _retSub;
  RetentionState _retentionState = RetentionState.emptyForDate(_todayKey());
  Timer? _nudge5;
  Timer? _nudge10;
  Timer? _nudge15;
  double? _currentLatitude;
  double? _currentLongitude;
  bool _locationDeniedNotified = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    unawaited(_syncCurrentLocation(showDeniedMessage: true)
        .then((_) => _loadProfiles()));
    _scheduleRetentionNudges();
    _entSub = widget.entitlementRepository
        .watchEntitlements(widget.currentUser.id)
        .listen((value) {
      if (!mounted) return;
      setState(() {
        final previousLimit = _entitlements.dailyLikesLimit();
        _entitlements = value;
        final newLimit = _entitlements.dailyLikesLimit();
        if (newLimit > previousLimit) {
          _dailyLikesLeft += (newLimit - previousLimit);
        }
      });
    });
    _prefSub = widget.profileRepository
        .watchPreferences(widget.currentUser.id)
        .listen((value) {
      if (!mounted) return;
      setState(() => _preferences = value);
      _loadProfiles();
    });
    _retSub = widget.retentionRepository
        .watchState(widget.currentUser.id)
        .listen((value) {
      if (!mounted) return;
      setState(() => _retentionState = value);
    });
  }

  @override
  void dispose() {
    _entSub?.cancel();
    _prefSub?.cancel();
    _retSub?.cancel();
    _nudge5?.cancel();
    _nudge10?.cancel();
    _nudge15?.cancel();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    final profiles = await widget.discoverRepository.fetchProfiles(
      currentUserId: widget.currentUser.id,
      preferences: _preferences,
      currentLatitude: _currentLatitude,
      currentLongitude: _currentLongitude,
    );
    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      if (_profileIndex >= _profiles.length) {
        _profileIndex = 0;
      }
    });
  }

  Future<void> _refreshProfiles() async {
    await _syncCurrentLocation(showDeniedMessage: false);
    await _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    const tabTitles = ['Descubrir', 'Matches', 'Chats', 'Premium', 'Perfil'];

    final tabs = [
      DiscoverTab(
        profiles: _profiles,
        profileIndex: _profileIndex,
        dailyLikesLeft: _dailyLikesLeft,
        superLikesLeft: _entitlements.superLikeCount,
        onPass: _nextProfile,
        onLike: _dailyLikesLeft > 0 ? _likeProfile : null,
        onSuperLike: _superLikeProfile,
        onBoostTap: _useBoost,
        onReportProfile: _reportCurrentProfile,
        onBlockProfile: _blockCurrentProfile,
        preferences: _preferences,
        quickFilterKey: _quickFilterKey,
        onSelectQuickFilter: _applyQuickFilter,
        retentionState: _retentionState,
        onClaimMission: _claimMission,
        onRefreshProfiles: _refreshProfiles,
      ),
      MatchesTab(
        currentUserId: widget.currentUser.id,
        matchRepository: widget.matchRepository,
        chatRepository: widget.chatRepository,
        onOpenChat: _recordChatOpened,
      ),
      ChatsTab(
        currentUserId: widget.currentUser.id,
        matchRepository: widget.matchRepository,
        chatRepository: widget.chatRepository,
        onOpenChat: _recordChatOpened,
      ),
      PremiumTab(
          userId: widget.currentUser.id,
          entitlementRepository: widget.entitlementRepository),
      ProfileTab(
        currentUserId: widget.currentUser.id,
        profileRepository: widget.profileRepository,
        safetyRepository: widget.safetyRepository,
        sessionLabel: widget.currentUser.sessionLabel,
        onLogout: widget.onLogout,
        onResetFeed: _resetFeed,
      ),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            tabTitles[_currentIndex],
            key: ValueKey(_currentIndex),
          ),
        ),
        actions: [
          _RewardsBadgeButton(
            pendingCount: _retentionState.missions
                .where((mission) => mission.completed && !mission.claimed)
                .length,
            onTap: () {
              UiFeedback.selection();
              setState(() => _currentIndex = 0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Revisa tus misiones de Early Access y reclama recompensas.'),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: FinderAtmosphere(
        child: SafeArea(
          top: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: tabs[_currentIndex],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              UiFeedback.selection();
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.favorite_outline), label: 'Descubrir'),
              NavigationDestination(
                  icon: Icon(Icons.people_outline), label: 'Matches'),
              NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
              NavigationDestination(
                  icon: Icon(Icons.workspace_premium_outlined),
                  label: 'Premium'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline), label: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }

  void _nextProfile() {
    if (_profiles.isNotEmpty) {
      final profile = _profiles[_profileIndex % _profiles.length];
      unawaited(
        widget.discoverRepository.markProfileSeen(
          currentUserId: widget.currentUser.id,
          targetUserId: profile.id,
          action: 'pass',
        ),
      );
    }
    setState(() => _profileIndex++);
  }

  Future<void> _likeProfile() async {
    if (_profiles.isEmpty) return;
    final profile = _profiles[_profileIndex % _profiles.length];
    final isMatch = await widget.matchRepository.sendLike(
      fromUserId: widget.currentUser.id,
      toUserId: profile.id,
    );
    await widget.discoverRepository.markProfileSeen(
      currentUserId: widget.currentUser.id,
      targetUserId: profile.id,
      action: 'like',
    );
    unawaited(
        widget.retentionRepository.recordLikeGiven(widget.currentUser.id));

    setState(() {
      _dailyLikesLeft--;
      _profileIndex++;
    });

    if (!mounted) return;
    if (isMatch) {
      unawaited(UiFeedback.emphasis());
      unawaited(showMatchCelebration(context, profile.name));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Match con ${profile.name}! Ya puedes chatear.')),
      );
    }
  }

  Future<void> _superLikeProfile() async {
    if (_profiles.isEmpty) return;
    if (_entitlements.superLikeCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No tienes Super Likes. Compra en Premium.')),
      );
      return;
    }

    final profile = _profiles[_profileIndex % _profiles.length];
    await widget.entitlementRepository.consumeSuperLike(widget.currentUser.id);
    final isMatch = await widget.matchRepository.sendLike(
      fromUserId: widget.currentUser.id,
      toUserId: profile.id,
    );
    await widget.discoverRepository.markProfileSeen(
      currentUserId: widget.currentUser.id,
      targetUserId: profile.id,
      action: 'super_like',
    );
    unawaited(
        widget.retentionRepository.recordSuperLikeGiven(widget.currentUser.id));

    setState(() => _profileIndex++);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Super Like enviado a ${profile.name}.')),
    );
    if (isMatch) {
      unawaited(UiFeedback.emphasis());
      unawaited(showMatchCelebration(context, profile.name));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match instantaneo con ${profile.name}!')),
      );
    }
  }

  Future<void> _useBoost() async {
    if (_entitlements.boostCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes boosts. Compra en Premium.')),
      );
      return;
    }
    await widget.entitlementRepository.consumeBoost(widget.currentUser.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Boost activado por 30 minutos.')),
    );
  }

  Future<void> _reportCurrentProfile() async {
    if (_profiles.isEmpty) return;
    final profile = _profiles[_profileIndex % _profiles.length];
    await widget.safetyRepository.reportUser(
      byUserId: widget.currentUser.id,
      targetUserId: profile.id,
      reason: 'reporte rapido desde discover',
    );
    await widget.discoverRepository.markProfileSeen(
      currentUserId: widget.currentUser.id,
      targetUserId: profile.id,
      action: 'report',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Perfil de ${profile.name} reportado.')),
    );
  }

  Future<void> _blockCurrentProfile() async {
    if (_profiles.isEmpty) return;
    final profile = _profiles[_profileIndex % _profiles.length];
    await widget.safetyRepository.blockUser(
      byUserId: widget.currentUser.id,
      targetUserId: profile.id,
    );
    await widget.discoverRepository.markProfileSeen(
      currentUserId: widget.currentUser.id,
      targetUserId: profile.id,
      action: 'block',
    );
    if (!mounted) return;
    setState(() => _profileIndex++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${profile.name} bloqueado.')),
    );
  }

  Future<void> _applyQuickFilter(String key) async {
    UserPreferences next = _preferences;
    if (key == 'all') {
      next = UserPreferences.defaults;
    } else if (key == 'nearby') {
      next = const UserPreferences(minAge: 18, maxAge: 40, maxDistanceKm: 5);
    } else if (key == '18_25') {
      next = const UserPreferences(minAge: 18, maxAge: 25, maxDistanceKm: 30);
    } else if (key == '25_35') {
      next = const UserPreferences(minAge: 25, maxAge: 35, maxDistanceKm: 30);
    }

    setState(() {
      _quickFilterKey = key;
      _preferences = next;
    });

    await widget.profileRepository.savePreferences(
      userId: widget.currentUser.id,
      preferences: next,
    );
    await _loadProfiles();
  }

  Future<void> _resetFeed() async {
    await widget.discoverRepository
        .clearSeenProfiles(currentUserId: widget.currentUser.id);
    if (!mounted) return;
    setState(() => _profileIndex = 0);
    await _loadProfiles();
  }

  Future<void> _claimMission(String missionId) async {
    final granted = await widget.retentionRepository.claimMission(
      userId: widget.currentUser.id,
      missionId: missionId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          granted
              ? 'Recompensa reclamada. Revisa tus Super Likes/Boosts.'
              : 'Mision aun no lista o ya reclamada hoy.',
        ),
      ),
    );
  }

  Future<void> _recordChatOpened() async {
    await widget.retentionRepository.recordChatOpened(widget.currentUser.id);
  }

  Future<void> _syncCurrentLocation({required bool showDeniedMessage}) async {
    final location = await widget.locationService.getCurrentLocation();
    if (!mounted) return;

    if (location == null) {
      if (showDeniedMessage && !_locationDeniedNotified) {
        _locationDeniedNotified = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Activa ubicacion para ver distancias reales cerca tuyo.'),
          ),
        );
      }
      return;
    }

    _locationDeniedNotified = false;
    _currentLatitude = location.latitude;
    _currentLongitude = location.longitude;
    await widget.profileRepository.saveCoordinates(
      userId: widget.currentUser.id,
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  void _scheduleRetentionNudges() {
    _nudge5 = Timer(const Duration(minutes: 5), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Tip Early Access: completa misiones de hoy y gana recompensas gratis.'),
        ),
      );
    });

    _nudge10 = Timer(const Duration(minutes: 10), () async {
      if (!mounted) return;
      await _refreshProfiles();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Actualizamos tu feed con nuevos perfiles compatibles.'),
        ),
      );
    });

    _nudge15 = Timer(const Duration(minutes: 15), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Abre un chat hoy y desbloquea una recompensa de Early Access.'),
        ),
      );
    });
  }
}

class _RewardsBadgeButton extends StatelessWidget {
  const _RewardsBadgeButton({
    required this.pendingCount,
    required this.onTap,
  });

  final int pendingCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.emoji_events_outlined),
            if (pendingCount > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    pendingCount > 9 ? '9+' : '$pendingCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _todayKey() {
  final now = DateTime.now();
  final mm = now.month.toString().padLeft(2, '0');
  final dd = now.day.toString().padLeft(2, '0');
  return '${now.year}-$mm-$dd';
}
