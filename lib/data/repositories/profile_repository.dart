import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_preferences.dart';
import '../models/user_profile.dart';

abstract class ProfileRepository {
  Stream<UserProfile?> watchProfile(String userId);
  Future<void> saveProfile(UserProfile profile);
  Future<void> saveCoordinates({
    required String userId,
    required double latitude,
    required double longitude,
  });
  Future<void> savePushToken({required String userId, required String token});
  Stream<UserPreferences> watchPreferences(String userId);
  Future<void> savePreferences(
      {required String userId, required UserPreferences preferences});
  Future<String?> uploadProfilePhoto({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  });
}

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

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
        photoUrl: data['photoUrl'] as String?,
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
      if (profile.photoUrl != null) 'photoUrl': profile.photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> saveCoordinates({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    await _firestore.collection('profiles').doc(userId).set({
      'latitude': latitude,
      'longitude': longitude,
      'locationUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> savePushToken(
      {required String userId, required String token}) async {
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
        minAge: (data['prefMinAge'] as num?)?.toInt() ??
            UserPreferences.defaults.minAge,
        maxAge: (data['prefMaxAge'] as num?)?.toInt() ??
            UserPreferences.defaults.maxAge,
        maxDistanceKm: (data['prefMaxDistanceKm'] as num?)?.toInt() ??
            UserPreferences.defaults.maxDistanceKm,
      );
    });
  }

  @override
  Future<void> savePreferences(
      {required String userId, required UserPreferences preferences}) async {
    await _firestore.collection('users').doc(userId).set({
      'prefMinAge': preferences.minAge,
      'prefMaxAge': preferences.maxAge,
      'prefMaxDistanceKm': preferences.maxDistanceKm,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<String?> uploadProfilePhoto({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final ext = fileExtension.isEmpty ? 'jpg' : fileExtension;
    final ref = _storage
        .ref()
        .child('profiles')
        .child(userId)
        .child('avatar_${DateTime.now().millisecondsSinceEpoch}.$ext');

    final metadata = SettableMetadata(contentType: 'image/$ext');
    final task = await ref.putData(bytes, metadata);
    final url = await task.ref.getDownloadURL();

    await _firestore.collection('profiles').doc(userId).set({
      'photoUrl': url,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return url;
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
  Future<void> saveCoordinates({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {}

  @override
  Future<void> savePushToken(
      {required String userId, required String token}) async {}

  @override
  Stream<UserProfile?> watchProfile(String userId) => _profileController.stream;

  @override
  Future<void> savePreferences(
      {required String userId, required UserPreferences preferences}) async {
    _preferences = preferences;
    _preferencesController.add(_preferences);
  }

  @override
  Stream<UserPreferences> watchPreferences(String userId) =>
      _preferencesController.stream;

  @override
  Future<String?> uploadProfilePhoto({
    required String userId,
    required Uint8List bytes,
    required String fileExtension,
  }) async {
    final mime = fileExtension.isEmpty ? 'jpeg' : fileExtension;
    final dataUrl = 'data:image/$mime;base64,${base64Encode(bytes)}';
    if (_profile == null) return dataUrl;

    _profile = UserProfile(
      id: _profile!.id,
      name: _profile!.name,
      age: _profile!.age,
      bio: _profile!.bio,
      distanceKm: _profile!.distanceKm,
      photoUrl: dataUrl,
    );
    _profileController.add(_profile);
    return dataUrl;
  }
}
