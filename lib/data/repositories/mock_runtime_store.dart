import 'dart:async';

import '../models/chat_message.dart';
import '../models/match_item.dart';

class MockRuntimeStore {
  static final StreamController<List<MatchItem>> _matchesController =
      StreamController<List<MatchItem>>.broadcast();

  static final Map<String, List<ChatMessage>> _messagesByMatchId = {};
  static final Map<String, StreamController<List<ChatMessage>>> _chatControllersByMatchId = {};
  static final List<MatchItem> _matches = [];
  static int _messageSeq = 0;

  static Stream<List<MatchItem>> watchMatches() => _matchesController.stream;

  static List<MatchItem> currentMatches() => List<MatchItem>.from(_matches);

  static void ensureSeedData() {
    if (_matches.isNotEmpty) return;
    final now = DateTime.now();
    _matches.addAll([
      MatchItem(
        id: 'mock_mia_24',
        userA: 'mock-user',
        userB: 'mia_24',
        lastMessage: 'Hola, te copa un cafe esta semana?',
        updatedAt: now.subtract(const Duration(minutes: 4)),
        lastSenderId: 'mia_24',
      ),
      MatchItem(
        id: 'mock_valen_22',
        userA: 'mock-user',
        userB: 'valen_22',
        lastMessage: 'Me encanto tu bio jaja',
        updatedAt: now.subtract(const Duration(minutes: 22)),
        lastSenderId: 'mock-user',
      ),
    ]);
    _messagesByMatchId['mock_mia_24'] = [
      const ChatMessage(id: 'm1', senderId: 'mia_24', text: 'Hola!'),
      const ChatMessage(id: 'm2', senderId: 'mock-user', text: 'Hey, todo bien?'),
      const ChatMessage(id: 'm3', senderId: 'mia_24', text: 'Hola, te copa un cafe esta semana?'),
    ];
    _messagesByMatchId['mock_valen_22'] = [
      const ChatMessage(id: 'v1', senderId: 'mock-user', text: 'Buenas!'),
      const ChatMessage(id: 'v2', senderId: 'valen_22', text: 'Hola :)'),
      const ChatMessage(id: 'v3', senderId: 'mock-user', text: 'Me encanto tu bio jaja'),
    ];
    _matchesController.add(currentMatches());
  }

  static void upsertMatch(MatchItem match) {
    final index = _matches.indexWhere((m) => m.id == match.id);
    if (index >= 0) {
      _matches[index] = match;
    } else {
      _matches.insert(0, match);
    }
    _matches.sort((a, b) {
      final aTime = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    _matchesController.add(currentMatches());
  }

  static Stream<List<ChatMessage>> watchMessages(String matchId) {
    final existingController = _chatControllersByMatchId[matchId];
    if (existingController != null) {
      return existingController.stream;
    }

    final controller = StreamController<List<ChatMessage>>.broadcast();
    _chatControllersByMatchId[matchId] = controller;
    controller.add(List<ChatMessage>.from(_messagesByMatchId[matchId] ?? const []));
    return controller.stream;
  }

  static void appendMessage({
    required String matchId,
    required String senderId,
    required String text,
  }) {
    final messages = _messagesByMatchId.putIfAbsent(matchId, () => <ChatMessage>[]);
    _messageSeq += 1;
    messages.add(ChatMessage(id: 'mock_msg_$_messageSeq', senderId: senderId, text: text));

    _chatControllersByMatchId[matchId]?.add(List<ChatMessage>.from(messages));

    final index = _matches.indexWhere((m) => m.id == matchId);
    if (index >= 0) {
      final current = _matches[index];
      upsertMatch(
        MatchItem(
          id: current.id,
          userA: current.userA,
          userB: current.userB,
          lastMessage: text,
          updatedAt: DateTime.now(),
          lastSenderId: senderId,
        ),
      );
    }
  }
}
