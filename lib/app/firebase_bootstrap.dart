import 'package:firebase_core/firebase_core.dart';

class FirebaseBootstrap {
  static bool _isAvailable = false;

  static bool get isAvailable => _isAvailable;

  static Future<void> ensureInitialized() async {
    try {
      await Firebase.initializeApp();
      _isAvailable = true;
    } catch (_) {
      _isAvailable = false;
    }
  }
}
