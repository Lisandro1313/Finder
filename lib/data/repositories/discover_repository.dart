import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/finder_profile.dart';
import '../models/user_preferences.dart';

abstract class DiscoverRepository {
  Future<List<FinderProfile>> fetchProfiles({
    required String currentUserId,
    required UserPreferences preferences,
    double? currentLatitude,
    double? currentLongitude,
  });
  Future<void> markProfileSeen({
    required String currentUserId,
    required String targetUserId,
    required String action,
  });
  Future<void> clearSeenProfiles({required String currentUserId});
}

class FirestoreDiscoverRepository implements DiscoverRepository {
  FirestoreDiscoverRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<FinderProfile>> fetchProfiles({
    required String currentUserId,
    required UserPreferences preferences,
    double? currentLatitude,
    double? currentLongitude,
  }) async {
    final seenSnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('seen_profiles')
        .limit(500)
        .get();
    final seenIds = seenSnapshot.docs.map((d) => d.id).toSet();

    final snapshot = await _firestore.collection('profiles').limit(100).get();
    final profiles = snapshot.docs
        .where((doc) => doc.id != currentUserId && !seenIds.contains(doc.id))
        .map((doc) {
          final data = doc.data();
          final fallbackDistanceKm =
              (data['distanceKm'] as num?)?.toInt() ?? 10;
          final targetLatitude = (data['latitude'] as num?)?.toDouble();
          final targetLongitude = (data['longitude'] as num?)?.toDouble();
          final realDistanceKm = _resolveDistanceKm(
            fallbackDistanceKm: fallbackDistanceKm,
            currentLatitude: currentLatitude,
            currentLongitude: currentLongitude,
            targetLatitude: targetLatitude,
            targetLongitude: targetLongitude,
          );

          return FinderProfile(
            id: doc.id,
            name: data['name'] as String? ?? 'Unknown',
            age: (data['age'] as num?)?.toInt() ?? 18,
            distanceKm: realDistanceKm,
            bio: data['bio'] as String? ?? 'Sin bio por ahora.',
            photoUrl: data['photoUrl'] as String?,
          );
        })
        .where(
            (p) => p.age >= preferences.minAge && p.age <= preferences.maxAge)
        .where((p) => p.distanceKm <= preferences.maxDistanceKm)
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    if (profiles.isEmpty) {
      return MockDiscoverRepository().fetchProfiles(
        currentUserId: currentUserId,
        preferences: preferences,
        currentLatitude: currentLatitude,
        currentLongitude: currentLongitude,
      );
    }

    return profiles;
  }

  @override
  Future<void> markProfileSeen({
    required String currentUserId,
    required String targetUserId,
    required String action,
  }) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('seen_profiles')
        .doc(targetUserId)
        .set({
      'action': action,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> clearSeenProfiles({required String currentUserId}) async {
    final coll = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('seen_profiles');
    final snap = await coll.limit(500).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

int _resolveDistanceKm({
  required int fallbackDistanceKm,
  required double? currentLatitude,
  required double? currentLongitude,
  required double? targetLatitude,
  required double? targetLongitude,
}) {
  if (currentLatitude == null ||
      currentLongitude == null ||
      targetLatitude == null ||
      targetLongitude == null) {
    return fallbackDistanceKm;
  }

  final km = _haversineKm(
      currentLatitude, currentLongitude, targetLatitude, targetLongitude);
  return km.round().clamp(1, 5000).toInt();
}

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_toRadians(lat1)) *
          math.cos(_toRadians(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadiusKm * c;
}

double _toRadians(double degrees) => degrees * math.pi / 180.0;

class MockDiscoverRepository implements DiscoverRepository {
  final Set<String> _seen = {};

  @override
  Future<List<FinderProfile>> fetchProfiles({
    required String currentUserId,
    required UserPreferences preferences,
    double? currentLatitude,
    double? currentLongitude,
  }) async {
    const all = [
      FinderProfile(
        id: 'mia_24',
        name: 'Mia',
        age: 24,
        distanceKm: 2,
        bio: 'Cafe, gym y viajes cortos.',
        photoUrl: null,
      ),
      FinderProfile(
        id: 'lucas_27',
        name: 'Lucas',
        age: 27,
        distanceKm: 4,
        bio: 'Sushi fan, perro lover, full buena onda.',
        photoUrl: null,
      ),
      FinderProfile(
        id: 'valen_22',
        name: 'Valen',
        age: 22,
        distanceKm: 1,
        bio: 'Me gusta bailar, hablar de todo y salir.',
        photoUrl: null,
      ),
    ];

    return all
        .where((p) => !_seen.contains(p.id))
        .where(
            (p) => p.age >= preferences.minAge && p.age <= preferences.maxAge)
        .where((p) => p.distanceKm <= preferences.maxDistanceKm)
        .toList();
  }

  @override
  Future<void> markProfileSeen({
    required String currentUserId,
    required String targetUserId,
    required String action,
  }) async {
    _seen.add(targetUserId);
  }

  @override
  Future<void> clearSeenProfiles({required String currentUserId}) async {
    _seen.clear();
  }
}
