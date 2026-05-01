class MatchItem {
  const MatchItem({
    required this.id,
    required this.userA,
    required this.userB,
    required this.lastMessage,
  });

  final String id;
  final String userA;
  final String userB;
  final String lastMessage;

  String otherUser(String currentUserId) {
    return currentUserId == userA ? userB : userA;
  }
}
