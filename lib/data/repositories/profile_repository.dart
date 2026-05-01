import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/user_preferences.dart';
import '../models/user_profile.dart';

abstract class ProfileRepository {
  Stream<UserProfile?> watchProfile(String userId);
  Future<void> saveProfile(UserProfile profile);
  Future<void> savePushToken({required String userId, required String token});
  Stream<UserPreferences> watchPreferences(String userId);
  Future<void> savePreferences({required String userId, required UserPreferences preferences});
}

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<UserProfile?> watchProfile(String userId) {
    return _firestore.collection('profiles').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return UserProfile(
        id: doc.id,
        name: data['name'] as String? ?? '',
        age: (data['age'] as num?)?.toInt() ?? 18,
        bio: data['bio'] as String? ?? '',
        distanceKm: (data['distanceKm'] as num?)?.toInt() ?? 10,
      );
    });
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _firestore.collection('profiles').doc(profile.id).set({
      'name': profile.name,
      'age': profile.age,
      'bio': profile.bio,
      'distanceKm': profile.distanceKm,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> savePushToken({required String userId, required String token}) async {
    await _firestore.collection('profiles').doc(userId).set({
      'pushToken': token,
      'pushTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Stream<UserPreferences> watchPreferences(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data() ?? <String, dynamic>{};
      return UserPreferences(
        minAge: (data['prefMinAge'] as num?)?.toInt() ?? UserPreferences.defaults.minAge,
        maxAge: (data['prefMaxAge'] as num?)?.toInt() ?? UserPreferences.defaults.maxAge,
        maxDistanceKm: (data['prefMaxDistanceKm'] as num?)?.toInt() ?? UserPreferences.defaults.maxDistanceKm,
      );
    });
  }

  @override
  Future<void> savePreferences({required String userId, required UserPreferences preferences}) async {
    await _firestore.collection('users').doc(userId).set({
      'prefMinAge': preferences.minAge,
      'prefMaxAge': preferences.maxAge,
      'prefMaxDistanceKm': preferences.maxDistanceKm,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

class MockProfileRepository implements ProfileRepository {
  MockProfileRepository() {
    _profileController.add(_profile);
    _preferencesController.add(_preferences);
  }

  UserProfile? _profile;
  UserPreferences _preferences = UserPreferences.defaults;
  final StreamController<UserProfile?> _profileController =
      StreamController<UserProfile?>.broadcast();
  final StreamController<UserPreferences> _preferencesController =
      StreamController<UserPreferences>.broadcast();

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    _profileController.add(_profile);
  }

  @override
  Future<void> savePushToken({required String userId, required String token}) async {}

  @override
  Stream<UserProfile?> watchProfile(String userId) => _profileController.stream;

  @override
  Future<void> savePreferences({required String userId, required UserPreferences preferences}) async {
    _preferences = preferences;
    _preferencesController.add(_preferences);
  }

  @override
  Stream<UserPreferences> watchPreferences(String userId) => _preferencesController.stream;
}
