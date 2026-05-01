import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

abstract class ProfileRepository {
  Stream<UserProfile?> watchProfile(String userId);
  Future<void> saveProfile(UserProfile profile);
  Future<void> savePushToken({required String userId, required String token});
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
}

class MockProfileRepository implements ProfileRepository {
  UserProfile? _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }

  @override
  Future<void> savePushToken({required String userId, required String token}) async {}

  @override
  Stream<UserProfile?> watchProfile(String userId) async* {
    yield _profile;
  }
}
