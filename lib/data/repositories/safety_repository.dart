import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/report_item.dart';

abstract class SafetyRepository {
  Future<void> blockUser({required String byUserId, required String targetUserId});
  Future<void> reportUser({
    required String byUserId,
    required String targetUserId,
    required String reason,
  });
  Future<bool> isBlockedEitherWay({required String userA, required String userB});
  Stream<bool> watchIsAdmin(String userId);
  Stream<List<ReportItem>> watchRecentReports();
  Future<void> markReportReviewed(String reportId, String reviewerId);
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
      'status': 'open',
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

  @override
  Stream<bool> watchIsAdmin(String userId) {
    return _firestore.collection('admin_users').doc(userId).snapshots().map((doc) => doc.exists);
  }

  @override
  Stream<List<ReportItem>> watchRecentReports() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => ReportItem(
              id: doc.id,
              byUserId: doc.data()['byUserId'] as String? ?? '',
              targetUserId: doc.data()['targetUserId'] as String? ?? '',
              reason: doc.data()['reason'] as String? ?? '',
              status: doc.data()['status'] as String? ?? 'open',
            ),
          )
          .toList();
    });
  }

  @override
  Future<void> markReportReviewed(String reportId, String reviewerId) async {
    await _firestore.collection('reports').doc(reportId).set({
      'status': 'reviewed',
      'reviewedBy': reviewerId,
      'reviewedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

class MockSafetyRepository implements SafetyRepository {
  @override
  Future<void> blockUser({required String byUserId, required String targetUserId}) async {}

  @override
  Future<bool> isBlockedEitherWay({required String userA, required String userB}) async => false;

  @override
  Future<void> reportUser({required String byUserId, required String targetUserId, required String reason}) async {}

  @override
  Stream<bool> watchIsAdmin(String userId) async* {
    yield false;
  }

  @override
  Stream<List<ReportItem>> watchRecentReports() async* {
    yield const [];
  }

  @override
  Future<void> markReportReviewed(String reportId, String reviewerId) async {}
}
