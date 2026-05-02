import 'package:flutter_test/flutter_test.dart';

import 'package:finder_app/data/repositories/auth_repository.dart';
import 'package:finder_app/data/repositories/chat_repository.dart';
import 'package:finder_app/data/repositories/discover_repository.dart';
import 'package:finder_app/data/repositories/entitlement_repository.dart';
import 'package:finder_app/data/repositories/match_repository.dart';
import 'package:finder_app/data/repositories/profile_repository.dart';
import 'package:finder_app/data/repositories/retention_repository.dart';
import 'package:finder_app/data/repositories/safety_repository.dart';
import 'package:finder_app/main.dart';
import 'package:finder_app/services/location_service.dart';

void main() {
  testWidgets('Finder app renders auth flow', (WidgetTester tester) async {
    await tester.pumpWidget(
      FinderApp(
        authRepository: MockAuthRepository(),
        profileRepository: MockProfileRepository(),
        discoverRepository: MockDiscoverRepository(),
        matchRepository: MockMatchRepository(),
        chatRepository: MockChatRepository(),
        entitlementRepository: MockEntitlementRepository(),
        retentionRepository: MockRetentionRepository(),
        safetyRepository: MockSafetyRepository(),
        locationService: MockLocationService(),
        notificationService: null,
      ),
    );

    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pump();

    expect(find.text('Continuar con Google'), findsOneWidget);
  });
}
