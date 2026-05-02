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
import '../data/repositories/retention_repository.dart';
import '../data/repositories/safety_repository.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/splash/finder_splash_screen.dart';
import '../services/location_service.dart';
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
    required this.retentionRepository,
    required this.safetyRepository,
    required this.locationService,
    required this.notificationService,
  });

  final AuthRepository authRepository;
  final ProfileRepository profileRepository;
  final DiscoverRepository discoverRepository;
  final MatchRepository matchRepository;
  final ChatRepository chatRepository;
  final EntitlementRepository entitlementRepository;
  final RetentionRepository retentionRepository;
  final SafetyRepository safetyRepository;
  final LocationService locationService;
  final NotificationService? notificationService;

  @override
  State<FinderRoot> createState() => _FinderRootState();
}

class _FinderRootState extends State<FinderRoot> {
  StreamSubscription<AppUser?>? _authSub;
  AppUser? _user;
  bool _isSigningIn = false;
  bool _showSplash = true;
  bool _authReady = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (!mounted || _authReady) return;
      setState(() => _authReady = true);
    });

    _authSub = widget.authRepository.authStateChanges().listen((user) async {
      if (!mounted) return;
      _authReady = true;
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
    if (_showSplash || !_authReady) {
      return const FinderSplashScreen();
    }

    if (_user == null) {
      return SignInScreen(
        isLoading: _isSigningIn,
        onContinueWithGoogle: _handleGoogleSignIn,
        onContinueAsGuest: _handleGuestSignIn,
      );
    }

    return StreamBuilder<UserProfile?>(
      stream: widget.profileRepository.watchProfile(_user!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data == null) {
          return OnboardingScreen(
            onSave: (
                {required name,
                required age,
                required bio,
                required distanceKm}) {
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
          retentionRepository: widget.retentionRepository,
          safetyRepository: widget.safetyRepository,
          locationService: widget.locationService,
          onLogout: widget.authRepository.signOut,
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
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

  Future<void> _handleGuestSignIn() async {
    setState(() => _isSigningIn = true);
    try {
      await widget.authRepository.signInAnonymously();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('No pudimos entrar como invitado. Revisa Firebase Auth.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }
}
