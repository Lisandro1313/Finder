import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models/app_user.dart';
import '../data/models/finder_profile.dart';
import '../data/models/user_entitlements.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/discover_repository.dart';
import '../data/repositories/entitlement_repository.dart';
import '../data/repositories/match_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/safety_repository.dart';
import '../features/chats/chats_tab.dart';
import '../features/discover/discover_tab.dart';
import '../features/matches/matches_tab.dart';
import '../features/premium/premium_tab.dart';
import '../features/profile/profile_tab.dart';

class FinderHome extends StatefulWidget {
  const FinderHome({
    super.key,
    required this.currentUser,
    required this.discoverRepository,
    required this.matchRepository,
    required this.chatRepository,
    required this.profileRepository,
    required this.entitlementRepository,
    required this.safetyRepository,
    required this.onLogout,
  });

  final AppUser currentUser;
  final DiscoverRepository discoverRepository;
  final MatchRepository matchRepository;
  final ChatRepository chatRepository;
  final ProfileRepository profileRepository;
  final EntitlementRepository entitlementRepository;
  final SafetyRepository safetyRepository;
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
  StreamSubscription<UserEntitlements>? _entSub;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _entSub = widget.entitlementRepository.watchEntitlements(widget.currentUser.id).listen((value) {
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
  }

  @override
  void dispose() {
    _entSub?.cancel();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    final profiles = await widget.discoverRepository.fetchProfiles(currentUserId: widget.currentUser.id);
    if (!mounted) return;
    setState(() => _profiles = profiles);
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      MatchesTab(currentUserId: widget.currentUser.id, matchRepository: widget.matchRepository),
      ChatsTab(
        currentUserId: widget.currentUser.id,
        matchRepository: widget.matchRepository,
        chatRepository: widget.chatRepository,
      ),
      PremiumTab(userId: widget.currentUser.id, entitlementRepository: widget.entitlementRepository),
      ProfileTab(
        currentUserId: widget.currentUser.id,
        profileRepository: widget.profileRepository,
        safetyRepository: widget.safetyRepository,
        sessionLabel: widget.currentUser.sessionLabel,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Finder')),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.favorite_outline), label: 'Descubrir'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Matches'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.workspace_premium_outlined), label: 'Premium'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  void _nextProfile() => setState(() => _profileIndex++);

  Future<void> _likeProfile() async {
    if (_profiles.isEmpty) return;
    final profile = _profiles[_profileIndex % _profiles.length];
    final isMatch = await widget.matchRepository.sendLike(
      fromUserId: widget.currentUser.id,
      toUserId: profile.id,
    );

    setState(() {
      _dailyLikesLeft--;
      _profileIndex++;
    });

    if (!mounted) return;
    if (isMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Match con ${profile.name}! Ya puedes chatear.')),
      );
    }
  }

  Future<void> _superLikeProfile() async {
    if (_profiles.isEmpty) return;
    if (_entitlements.superLikeCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes Super Likes. Compra en Premium.')),
      );
      return;
    }

    final profile = _profiles[_profileIndex % _profiles.length];
    await widget.entitlementRepository.consumeSuperLike(widget.currentUser.id);
    final isMatch = await widget.matchRepository.sendLike(
      fromUserId: widget.currentUser.id,
      toUserId: profile.id,
    );

    setState(() => _profileIndex++);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Super Like enviado a ${profile.name}.')),
    );
    if (isMatch) {
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
    if (!mounted) return;
    setState(() => _profileIndex++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${profile.name} bloqueado.')),
    );
  }
}
