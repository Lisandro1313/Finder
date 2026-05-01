import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models/app_user.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/discover_repository.dart';
import '../data/repositories/entitlement_repository.dart';
import '../data/repositories/match_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/safety_repository.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../services/notification_service.dart';
import 'finder_home.dart';

class FinderRoot extends StatefulWidget {
  const FinderRoot({
    super.key,
    required this.authRepository,
    required this.profileRepository,
    required this.discoverRepository,
    required this.matchRepository,
    required this.chatRepository,
    required this.entitlementRepository,
    required this.safetyRepository,
    required this.notificationService,
  });

  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final DiscoverRepository discoverRepository;
  final MatchRepository matchRepository;
  final ChatRepository chatRepository;
  final EntitlementRepository entitlementRepository;
  final SafetyRepository safetyRepository;
  final NotificationService? notificationService;

  @override
  State<FinderRoot> createState() => _FinderRootState();
}

class _FinderRootState extends State<FinderRoot> {
  StreamSubscription<AppUser?>? _authSub;
  AppUser? _user;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    _authSub = widget.authRepository.authStateChanges().listen((user) async {
      if (!mounted) return;
      if (user != null && widget.notificationService != null) {
        await widget.notificationService!.initialize(user.id);
      }
      setState(() => _user = user);
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return SignInScreen(isLoading: _isSigningIn, onContinue: _handleSignIn);
    }

    return StreamBuilder<UserProfile?>(
      stream: widget.profileRepository.watchProfile(_user!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data == null) {
          return OnboardingScreen(
            onSave: ({required name, required age, required bio, required distanceKm}) {
              return widget.profileRepository.saveProfile(
                UserProfile(
                  id: _user!.id,
                  name: name,
                  age: age,
                  bio: bio,
                  distanceKm: distanceKm,
                ),
              );
            },
          );
        }

        return FinderHome(
          currentUser: _user!,
          discoverRepository: widget.discoverRepository,
          matchRepository: widget.matchRepository,
          chatRepository: widget.chatRepository,
          profileRepository: widget.profileRepository,
          entitlementRepository: widget.entitlementRepository,
          safetyRepository: widget.safetyRepository,
          onLogout: widget.authRepository.signOut,
        );
      },
    );
  }

  Future<void> _handleSignIn() async {
    setState(() => _isSigningIn = true);
    try {
      await widget.authRepository.signIn();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos iniciar sesion. Reintenta.')),
      );
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }
}
