import 'package:flutter/services.dart';

class UiFeedback {
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
    await SystemSound.play(SystemSoundType.click);
  }

  static Future<void> success() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> emphasis() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> warning() async {
    await HapticFeedback.heavyImpact();
  }
}
