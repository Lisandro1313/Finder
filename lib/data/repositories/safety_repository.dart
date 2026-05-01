import 'package:cloud_firestore/cloud_firestore.dart';

abstract class SafetyRepository {
  Future<void> blockUser({required String byUserId, required String targetUserId});
  Future<void> reportUser({
    required String byUserId,
    required String targetUserId,
    required String reason,
  });
  Future<bool> isBlockedEitherWay({required String userA, required String userB});
}

class FirestoreSafetyRepository implements SafetyRepository {
  FirestoreSafetyRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> blockUser({required String byUserId, required String targetUserId}) async {
    final id = '${byUserId}_$targetUserId';
    await _firestore.collection('blocks').doc(id).set({
      'byUserId': byUserId,
      'targetUserId': targetUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> reportUser({required String byUserId, required String targetUserId, required String reason}) async {
    await _firestore.collection('reports').add({
      'byUserId': byUserId,
      'targetUserId': targetUserId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<bool> isBlockedEitherWay({required String userA, required String userB}) async {
    final one = await _firestore.collection('blocks').doc('${userA}_$userB').get();
    if (one.exists) return true;
    final two = await _firestore.collection('blocks').doc('${userB}_$userA').get();
    return two.exists;
  }
}

class MockSafetyRepository implements SafetyRepository {
  @override
  Future<void> blockUser({required String byUserId, required String targetUserId}) async {}

  @override
  Future<bool> isBlockedEitherWay({required String userA, required String userB}) async => false;

  @override
  Future<void> reportUser({required String byUserId, required String targetUserId, required String reason}) async {}
}
