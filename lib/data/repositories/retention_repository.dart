import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/retention_state.dart';

abstract class RetentionRepository {
  Stream<RetentionState> watchState(String userId);
  Future<void> recordLikeGiven(String userId);
  Future<void> recordSuperLikeGiven(String userId);
  Future<void> recordChatOpened(String userId);
  Future<bool> claimMission({required String userId, required String missionId});
}

class FirestoreRetentionRepository implements RetentionRepository {
  FirestoreRetentionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<RetentionState> watchState(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data() ?? <String, dynamic>{};
      final today = _todayKey();
      final sameDay = (data['retentionDateKey'] as String? ?? '') == today;

      final likes = sameDay ? (data['retentionLikesToday'] as num?)?.toInt() ?? 0 : 0;
      final superLikes = sameDay ? (data['retentionSuperLikesToday'] as num?)?.toInt() ?? 0 : 0;
      final chatsOpened = sameDay ? (data['retentionChatsOpenedToday'] as num?)?.toInt() ?? 0 : 0;

      final claimLikes = sameDay ? data['retentionClaimLikes'] as bool? ?? false : false;
      final claimSuper = sameDay ? data['retentionClaimSuperLike'] as bool? ?? false : false;
      final claimChat = sameDay ? data['retentionClaimChat'] as bool? ?? false : false;

      return RetentionState(
        earlyAccess: true,
        dateKey: today,
        likesToday: likes,
        superLikesToday: superLikes,
        chatsOpenedToday: chatsOpened,
        missions: [
          RetentionMission(
            id: _missionLikes,
            title: 'Mision: 5 likes',
            description: 'Da 5 likes hoy y desbloquea 1 Super Like.',
            progress: likes,
            target: 5,
            claimed: claimLikes,
            rewardSuperLikes: 1,
            rewardBoosts: 0,
          ),
          RetentionMission(
            id: _missionSuperLike,
            title: 'Mision: 1 Super Like',
            description: 'Usa 1 Super Like hoy y desbloquea 1 Boost.',
            progress: superLikes,
            target: 1,
            claimed: claimSuper,
            rewardSuperLikes: 0,
            rewardBoosts: 1,
          ),
          RetentionMission(
            id: _missionChat,
            title: 'Mision: abrir 1 chat',
            description: 'Abre al menos 1 chat hoy y gana 1 Super Like.',
            progress: chatsOpened,
            target: 1,
            claimed: claimChat,
            rewardSuperLikes: 1,
            rewardBoosts: 0,
          ),
        ],
      );
    });
  }

  @override
  Future<void> recordLikeGiven(String userId) async {
    await _incrementDaily(userId: userId, field: 'retentionLikesToday', by: 1);
  }

  @override
  Future<void> recordSuperLikeGiven(String userId) async {
    await _incrementDaily(userId: userId, field: 'retentionSuperLikesToday', by: 1);
  }

  @override
  Future<void> recordChatOpened(String userId) async {
    await _incrementDaily(userId: userId, field: 'retentionChatsOpenedToday', by: 1);
  }

  @override
  Future<bool> claimMission({required String userId, required String missionId}) async {
    final userRef = _firestore.collection('users').doc(userId);
    final today = _todayKey();
    var granted = false;

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = snap.data() ?? <String, dynamic>{};
      final sameDay = (data['retentionDateKey'] as String? ?? '') == today;

      final likes = sameDay ? (data['retentionLikesToday'] as num?)?.toInt() ?? 0 : 0;
      final superLikes = sameDay ? (data['retentionSuperLikesToday'] as num?)?.toInt() ?? 0 : 0;
      final chatsOpened = sameDay ? (data['retentionChatsOpenedToday'] as num?)?.toInt() ?? 0 : 0;

      final claimLikes = sameDay ? data['retentionClaimLikes'] as bool? ?? false : false;
      final claimSuper = sameDay ? data['retentionClaimSuperLike'] as bool? ?? false : false;
      final claimChat = sameDay ? data['retentionClaimChat'] as bool? ?? false : false;

      final patch = <String, dynamic>{
        'retentionDateKey': today,
      };

      if (missionId == _missionLikes && !claimLikes && likes >= 5) {
        final current = (data['superLikeCount'] as num?)?.toInt() ?? 0;
        patch['superLikeCount'] = current + 1;
        patch['retentionClaimLikes'] = true;
        granted = true;
      }

      if (missionId == _missionSuperLike && !claimSuper && superLikes >= 1) {
        final current = (data['boostCount'] as num?)?.toInt() ?? 0;
        patch['boostCount'] = current + 1;
        patch['retentionClaimSuperLike'] = true;
        granted = true;
      }

      if (missionId == _missionChat && !claimChat && chatsOpened >= 1) {
        final current = (data['superLikeCount'] as num?)?.toInt() ?? 0;
        patch['superLikeCount'] = current + 1;
        patch['retentionClaimChat'] = true;
        granted = true;
      }

      if (granted) {
        tx.set(userRef, patch, SetOptions(merge: true));
      }
    });

    return granted;
  }

  Future<void> _incrementDaily({
    required String userId,
    required String field,
    required int by,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final today = _todayKey();

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = snap.data() ?? <String, dynamic>{};
      final sameDay = (data['retentionDateKey'] as String? ?? '') == today;

      final likes = sameDay ? (data['retentionLikesToday'] as num?)?.toInt() ?? 0 : 0;
      final superLikes = sameDay ? (data['retentionSuperLikesToday'] as num?)?.toInt() ?? 0 : 0;
      final chats = sameDay ? (data['retentionChatsOpenedToday'] as num?)?.toInt() ?? 0 : 0;

      final next = <String, dynamic>{
        'retentionDateKey': today,
        'retentionLikesToday': likes,
        'retentionSuperLikesToday': superLikes,
        'retentionChatsOpenedToday': chats,
      };

      if (!sameDay) {
        next['retentionClaimLikes'] = false;
        next['retentionClaimSuperLike'] = false;
        next['retentionClaimChat'] = false;
      }

      final current = (next[field] as int?) ?? 0;
      next[field] = current + by;

      tx.set(userRef, next, SetOptions(merge: true));
    });
  }
}

class MockRetentionRepository implements RetentionRepository {
  final StreamController<RetentionState> _controller =
      StreamController<RetentionState>.broadcast();
  int _likes = 0;
  int _superLikes = 0;
  int _chats = 0;
  bool _claimLikes = false;
  bool _claimSuper = false;
  bool _claimChat = false;

  MockRetentionRepository() {
    _emit();
  }

  @override
  Stream<RetentionState> watchState(String userId) => _controller.stream;

  @override
  Future<void> recordLikeGiven(String userId) async {
    _likes += 1;
    _emit();
  }

  @override
  Future<void> recordSuperLikeGiven(String userId) async {
    _superLikes += 1;
    _emit();
  }

  @override
  Future<void> recordChatOpened(String userId) async {
    _chats += 1;
    _emit();
  }

  @override
  Future<bool> claimMission({required String userId, required String missionId}) async {
    var granted = false;
    if (missionId == _missionLikes && !_claimLikes && _likes >= 5) {
      _claimLikes = true;
      granted = true;
    } else if (missionId == _missionSuperLike && !_claimSuper && _superLikes >= 1) {
      _claimSuper = true;
      granted = true;
    } else if (missionId == _missionChat && !_claimChat && _chats >= 1) {
      _claimChat = true;
      granted = true;
    }
    _emit();
    return granted;
  }

  void _emit() {
    final nowKey = _todayKey();
    _controller.add(
      RetentionState(
        earlyAccess: true,
        dateKey: nowKey,
        likesToday: _likes,
        superLikesToday: _superLikes,
        chatsOpenedToday: _chats,
        missions: [
          RetentionMission(
            id: _missionLikes,
            title: 'Mision: 5 likes',
            description: 'Da 5 likes hoy y desbloquea 1 Super Like.',
            progress: _likes,
            target: 5,
            claimed: _claimLikes,
            rewardSuperLikes: 1,
            rewardBoosts: 0,
          ),
          RetentionMission(
            id: _missionSuperLike,
            title: 'Mision: 1 Super Like',
            description: 'Usa 1 Super Like hoy y desbloquea 1 Boost.',
            progress: _superLikes,
            target: 1,
            claimed: _claimSuper,
            rewardSuperLikes: 0,
            rewardBoosts: 1,
          ),
          RetentionMission(
            id: _missionChat,
            title: 'Mision: abrir 1 chat',
            description: 'Abre al menos 1 chat hoy y gana 1 Super Like.',
            progress: _chats,
            target: 1,
            claimed: _claimChat,
            rewardSuperLikes: 1,
            rewardBoosts: 0,
          ),
        ],
      ),
    );
  }
}

const _missionLikes = 'mission_likes_5';
const _missionSuperLike = 'mission_superlike_1';
const _missionChat = 'mission_chat_1';

String _todayKey() {
  final now = DateTime.now();
  final mm = now.month.toString().padLeft(2, '0');
  final dd = now.day.toString().padLeft(2, '0');
  return '${now.year}-$mm-$dd';
}
