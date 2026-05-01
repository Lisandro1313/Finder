class MatchItem {
  const MatchItem({
    required this.id,
    required this.userA,
    required this.userB,
    required this.lastMessage,
    this.updatedAt,
    this.lastSenderId,
  });

  final String id;
  final String userA;
  final String userB;
  final String lastMessage;
  final DateTime? updatedAt;
  final String? lastSenderId;

  String otherUser(String currentUserId) {
    return currentUserId == userA ? userB : userA;
  }
}
