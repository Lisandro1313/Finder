import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/finder_profile.dart';

abstract class DiscoverRepository {
  Future<List<FinderProfile>> fetchProfiles({required String currentUserId});
}

class FirestoreDiscoverRepository implements DiscoverRepository {
  FirestoreDiscoverRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<FinderProfile>> fetchProfiles({required String currentUserId}) async {
    final snapshot = await _firestore.collection('profiles').limit(50).get();
    final profiles = snapshot.docs
        .where((doc) => doc.id != currentUserId)
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
        .toList();

    if (profiles.isEmpty) {
      return MockDiscoverRepository().fetchProfiles(currentUserId: currentUserId);
    }

    return profiles;
  }
}

class MockDiscoverRepository implements DiscoverRepository {
  @override
  Future<List<FinderProfile>> fetchProfiles({required String currentUserId}) async {
    return const [
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
  }
}
