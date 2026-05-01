import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app/firebase_bootstrap.dart';
import 'app/finder_root.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/discover_repository.dart';
import 'data/repositories/entitlement_repository.dart';
import 'data/repositories/match_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/safety_repository.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseBootstrap.ensureInitialized();

  final authRepository = FirebaseBootstrap.isAvailable
      ? FirebaseAuthRepository(FirebaseAuth.instance)
      : MockAuthRepository();
  final profileRepository = FirebaseBootstrap.isAvailable
      ? FirestoreProfileRepository(FirebaseFirestore.instance)
      : MockProfileRepository();
  final discoverRepository = FirebaseBootstrap.isAvailable
      ? FirestoreDiscoverRepository(FirebaseFirestore.instance)
      : MockDiscoverRepository();
  final safetyRepository = FirebaseBootstrap.isAvailable
      ? FirestoreSafetyRepository(FirebaseFirestore.instance)
      : MockSafetyRepository();
  final matchRepository = FirebaseBootstrap.isAvailable
      ? FirestoreMatchRepository(FirebaseFirestore.instance, safetyRepository)
      : MockMatchRepository();
  final chatRepository = FirebaseBootstrap.isAvailable
      ? FirestoreChatRepository(FirebaseFirestore.instance)
      : MockChatRepository();
  final entitlementRepository = FirebaseBootstrap.isAvailable
      ? FirestoreEntitlementRepository(FirebaseFirestore.instance)
      : MockEntitlementRepository();
  final notificationService = FirebaseBootstrap.isAvailable
      ? NotificationService(FirebaseMessaging.instance, profileRepository)
      : null;

  runApp(FinderApp(
    authRepository: authRepository,
    profileRepository: profileRepository,
    discoverRepository: discoverRepository,
    matchRepository: matchRepository,
    chatRepository: chatRepository,
    entitlementRepository: entitlementRepository,
    safetyRepository: safetyRepository,
    notificationService: notificationService,
  ));
}

class FinderApp extends StatelessWidget {
  const FinderApp({
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEF476F)),
        useMaterial3: true,
      ),
      home: FinderRoot(
        authRepository: authRepository,
        profileRepository: profileRepository,
        discoverRepository: discoverRepository,
        matchRepository: matchRepository,
        chatRepository: chatRepository,
        entitlementRepository: entitlementRepository,
        safetyRepository: safetyRepository,
        notificationService: notificationService,
      ),
    );
  }
}
