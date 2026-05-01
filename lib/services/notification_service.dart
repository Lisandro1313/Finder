import 'package:firebase_messaging/firebase_messaging.dart';

import '../data/repositories/profile_repository.dart';

class NotificationService {
  NotificationService(this._messaging, this._profileRepository);

  final FirebaseMessaging _messaging;
  final ProfileRepository _profileRepository;

  Future<void> initialize(String userId) async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    final token = await _messaging.getToken();
    if (token != null) {
      await _profileRepository.savePushToken(userId: userId, token: token);
    }
  }
}
