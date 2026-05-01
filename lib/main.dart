import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  const useMockBackend = bool.fromEnvironment(
    'FINDER_USE_MOCK_BACKEND',
    defaultValue: kIsWeb && kDebugMode,
  );
  final useFirebaseBackend = FirebaseBootstrap.isAvailable && !useMockBackend;

  final authRepository = useFirebaseBackend
      ? FirebaseAuthRepository(FirebaseAuth.instance, GoogleSignIn())
      : MockAuthRepository();
  final profileRepository = useFirebaseBackend
      ? FirestoreProfileRepository(FirebaseFirestore.instance)
      : MockProfileRepository();
  final discoverRepository = useFirebaseBackend
      ? FirestoreDiscoverRepository(FirebaseFirestore.instance)
      : MockDiscoverRepository();
  final safetyRepository = useFirebaseBackend
      ? FirestoreSafetyRepository(FirebaseFirestore.instance)
      : MockSafetyRepository();
  final matchRepository = useFirebaseBackend
      ? FirestoreMatchRepository(FirebaseFirestore.instance, safetyRepository)
      : MockMatchRepository();
  final chatRepository = useFirebaseBackend
      ? FirestoreChatRepository(FirebaseFirestore.instance)
      : MockChatRepository();
  final entitlementRepository = useFirebaseBackend
      ? FirestoreEntitlementRepository(FirebaseFirestore.instance)
      : MockEntitlementRepository();
  final notificationService = useFirebaseBackend
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
