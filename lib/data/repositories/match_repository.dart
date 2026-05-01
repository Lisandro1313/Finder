import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match_item.dart';
import 'mock_runtime_store.dart';
import 'safety_repository.dart';

abstract class MatchRepository {
  Future<bool> sendLike({required String fromUserId, required String toUserId});
  Stream<List<MatchItem>> watchMatches(String userId);
}

class FirestoreMatchRepository implements MatchRepository {
  FirestoreMatchRepository(this._firestore, this._safetyRepository);

  final FirebaseFirestore _firestore;
  final SafetyRepository _safetyRepository;

  @override
  Future<bool> sendLike({required String fromUserId, required String toUserId}) async {
    final blocked = await _safetyRepository.isBlockedEitherWay(userA: fromUserId, userB: toUserId);
    if (blocked) return false;

    final likeId = '${fromUserId}_$toUserId';
    final reciprocalLikeId = '${toUserId}_$fromUserId';

    await _firestore.collection('likes').doc(likeId).set({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final reciprocal = await _firestore.collection('likes').doc(reciprocalLikeId).get();
    if (!reciprocal.exists) return false;

    final users = [fromUserId, toUserId]..sort();
    final matchId = '${users[0]}_${users[1]}';

    await _firestore.collection('matches').doc(matchId).set({
      'users': users,
      'lastMessage': 'Se hizo match. Rompe el hielo!',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return true;
  }

  @override
  Stream<List<MatchItem>> watchMatches(String userId) {
    return _firestore
        .collection('matches')
        .where('users', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final users = (data['users'] as List<dynamic>? ?? []).cast<String>();
        final userA = users.isNotEmpty ? users[0] : '';
        final userB = users.length > 1 ? users[1] : '';

        return MatchItem(
          id: doc.id,
          userA: userA,
          userB: userB,
          lastMessage: data['lastMessage'] as String? ?? 'Nuevo match',
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
          lastSenderId: data['lastSenderId'] as String?,
        );
      }).toList();
    });
  }
}

class MockMatchRepository implements MatchRepository {
  MockMatchRepository() {
    MockRuntimeStore.ensureSeedData();
  }

  @override
  Future<bool> sendLike({required String fromUserId, required String toUserId}) async {
    final users = [fromUserId, toUserId]..sort();
    final matchId = 'mock_${users[0]}_${users[1]}';
    final match = MatchItem(
      id: matchId,
      userA: users[0],
      userB: users[1],
      lastMessage: 'Se hizo match. Rompe el hielo!',
      updatedAt: DateTime.now(),
      lastSenderId: fromUserId,
    );
    MockRuntimeStore.upsertMatch(match);
    return true;
  }

  @override
  Stream<List<MatchItem>> watchMatches(String userId) {
    return MockRuntimeStore.watchMatches().map(
      (matches) => matches.where((m) => m.userA == userId || m.userB == userId).toList(),
    );
  }
}
