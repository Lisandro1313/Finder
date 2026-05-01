class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
  });

  final String id;
  final String senderId;
  final String text;
}
