import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'data/repositories/retention_repository.dart';
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
      ? FirestoreProfileRepository(FirebaseFirestore.instance, FirebaseStorage.instance)
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
  final retentionRepository = useFirebaseBackend
      ? FirestoreRetentionRepository(FirebaseFirestore.instance)
      : MockRetentionRepository();
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
    retentionRepository: retentionRepository,
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
    required this.retentionRepository,
    required this.safetyRepository,
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
  final NotificationService? notificationService;

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFFE11D48);
    const accent = Color(0xFFFF6B6B);
    const neutralBg = Color(0xFFF8F7FC);
    final baseScheme = ColorScheme.fromSeed(seedColor: brand);

    return MaterialApp(
      title: 'Finder',
      theme: ThemeData(
        colorScheme: baseScheme.copyWith(
          primary: brand,
          secondary: accent,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: neutralBg,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1F1B2D),
          titleTextStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F1B2D),
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        textTheme: ThemeData.light().textTheme.copyWith(
              displaySmall: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F1B2D),
                letterSpacing: -1.2,
              ),
              headlineSmall: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F1B2D),
                letterSpacing: -0.6,
              ),
              titleMedium: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1B2D),
              ),
              bodyLarge: const TextStyle(
                fontSize: 18,
                height: 1.4,
                color: Color(0xFF3A3451),
              ),
              bodyMedium: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFF5A546F),
              ),
            ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: brand, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1F1B2D),
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Color(0xFFD8D3E8)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white.withOpacity(0.90),
          indicatorColor: const Color(0x1AE11D48),
          iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((states) {
            final selected = states.contains(MaterialState.selected);
            return IconThemeData(
              color: selected ? const Color(0xFFE11D48) : const Color(0xFF736A8A),
            );
          }),
          labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((states) {
            final selected = states.contains(MaterialState.selected);
            return TextStyle(
              color: selected ? const Color(0xFFE11D48) : const Color(0xFF736A8A),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            );
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2C2640),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          contentTextStyle: const TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: FinderRoot(
        authRepository: authRepository,
        profileRepository: profileRepository,
        discoverRepository: discoverRepository,
        matchRepository: matchRepository,
        chatRepository: chatRepository,
        entitlementRepository: entitlementRepository,
        retentionRepository: retentionRepository,
        safetyRepository: safetyRepository,
        notificationService: notificationService,
      ),
    );
  }
}
