import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_message.dart';

abstract class ChatRepository {
  Stream<List<ChatMessage>> watchMessages(String matchId);
  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  });
}

class FirestoreChatRepository implements ChatRepository {
  FirestoreChatRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await _firestore.collection('matches').doc(matchId).set({
      'lastMessage': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _firestore.collection('chats').doc(matchId).collection('messages').add({
      'senderId': senderId,
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String matchId) {
    return _firestore
        .collection('chats')
        .doc(matchId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => ChatMessage(
              id: doc.id,
              senderId: doc.data()['senderId'] as String? ?? '',
              text: doc.data()['text'] as String? ?? '',
            ),
          )
          .toList();
    });
  }
}

class MockChatRepository implements ChatRepository {
  @override
  Future<void> sendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) async {}

  @override
  Stream<List<ChatMessage>> watchMessages(String matchId) async* {
    yield const [];
  }
}
