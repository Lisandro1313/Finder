import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/finder_profile.dart';
import '../models/user_preferences.dart';

abstract class DiscoverRepository {
  Future<List<FinderProfile>> fetchProfiles({
    required String currentUserId,
    required UserPreferences preferences,
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
  Future<List<FinderProfile>> fetchProfiles({required String currentUserId, required UserPreferences preferences}) async {
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
          return FinderProfile(
            id: doc.id,
            name: data['name'] as String? ?? 'Unknown',
            age: (data['age'] as num?)?.toInt() ?? 18,
            distanceKm: (data['distanceKm'] as num?)?.toInt() ?? 1,
            bio: data['bio'] as String? ?? 'Sin bio por ahora.',
          );
        })
        .where((p) => p.age >= preferences.minAge && p.age <= preferences.maxAge)
        .where((p) => p.distanceKm <= preferences.maxDistanceKm)
        .toList();

    if (profiles.isEmpty) {
      return MockDiscoverRepository().fetchProfiles(currentUserId: currentUserId, preferences: preferences);
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
    final coll = _firestore.collection('users').doc(currentUserId).collection('seen_profiles');
    final snap = await coll.limit(500).get();
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

class MockDiscoverRepository implements DiscoverRepository {
  final Set<String> _seen = {};

  @override
  Future<List<FinderProfile>> fetchProfiles({required String currentUserId, required UserPreferences preferences}) async {
    const all = [
      FinderProfile(
        id: 'mia_24',
        name: 'Mia',
        age: 24,
        distanceKm: 2,
        bio: 'Cafe, gym y viajes cortos.',
      ),
      FinderProfile(
        id: 'lucas_27',
        name: 'Lucas',
        age: 27,
        distanceKm: 4,
        bio: 'Sushi fan, perro lover, full buena onda.',
      ),
      FinderProfile(
        id: 'valen_22',
        name: 'Valen',
        age: 22,
        distanceKm: 1,
        bio: 'Me gusta bailar, hablar de todo y salir.',
      ),
    ];

    return all
        .where((p) => !_seen.contains(p.id))
        .where((p) => p.age >= preferences.minAge && p.age <= preferences.maxAge)
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
