import 'package:cloud_firestore/cloud_firestore.dart';

import '../../billing/finder_products.dart';
import '../models/user_entitlements.dart';

abstract class EntitlementRepository {
  Stream<UserEntitlements> watchEntitlements(String userId);
  Future<void> applyPurchase({required String userId, required String productId});
  Future<void> consumeBoost(String userId);
  Future<void> consumeSuperLike(String userId);
}

class FirestoreEntitlementRepository implements EntitlementRepository {
  FirestoreEntitlementRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<UserEntitlements> watchEntitlements(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data() ?? <String, dynamic>{};
      return UserEntitlements(
        plusActive: data['plusActive'] as bool? ?? false,
        boostCount: (data['boostCount'] as num?)?.toInt() ?? 0,
        superLikeCount: (data['superLikeCount'] as num?)?.toInt() ?? 0,
      );
    });
  }

  @override
  Future<void> applyPurchase({required String userId, required String productId}) async {
    final userRef = _firestore.collection('users').doc(userId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = snap.data() ?? <String, dynamic>{};
      var plusActive = data['plusActive'] as bool? ?? false;
      var boostCount = (data['boostCount'] as num?)?.toInt() ?? 0;
      var superLikeCount = (data['superLikeCount'] as num?)?.toInt() ?? 0;

      if (productId == FinderProducts.plusSubscription) plusActive = true;
      if (productId == FinderProducts.boostPack) boostCount += 5;
      if (productId == FinderProducts.superLikePack) superLikeCount += 10;

      tx.set(userRef, {
        'plusActive': plusActive,
        'boostCount': boostCount,
        'superLikeCount': superLikeCount,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> consumeBoost(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = snap.data() ?? <String, dynamic>{};
      final boostCount = (data['boostCount'] as num?)?.toInt() ?? 0;
      if (boostCount <= 0) return;
      tx.set(userRef, {'boostCount': boostCount - 1}, SetOptions(merge: true));
    });
  }

  @override
  Future<void> consumeSuperLike(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = snap.data() ?? <String, dynamic>{};
      final count = (data['superLikeCount'] as num?)?.toInt() ?? 0;
      if (count <= 0) return;
      tx.set(userRef, {'superLikeCount': count - 1}, SetOptions(merge: true));
    });
  }
}

class MockEntitlementRepository implements EntitlementRepository {
  UserEntitlements _entitlements = UserEntitlements.empty;

  @override
  Stream<UserEntitlements> watchEntitlements(String userId) async* {
    yield _entitlements;
  }

  @override
  Future<void> applyPurchase({required String userId, required String productId}) async {
    if (productId == FinderProducts.plusSubscription) {
      _entitlements = _entitlements.copyWith(plusActive: true);
    }
    if (productId == FinderProducts.boostPack) {
      _entitlements = _entitlements.copyWith(boostCount: _entitlements.boostCount + 5);
    }
    if (productId == FinderProducts.superLikePack) {
      _entitlements = _entitlements.copyWith(superLikeCount: _entitlements.superLikeCount + 10);
    }
  }

  @override
  Future<void> consumeBoost(String userId) async {
    if (_entitlements.boostCount > 0) {
      _entitlements = _entitlements.copyWith(boostCount: _entitlements.boostCount - 1);
    }
  }

  @override
  Future<void> consumeSuperLike(String userId) async {
    if (_entitlements.superLikeCount > 0) {
      _entitlements = _entitlements.copyWith(superLikeCount: _entitlements.superLikeCount - 1);
    }
  }
}
