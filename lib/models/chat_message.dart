class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.message,
    required this.username,
    required this.createdAt,
  });

  final int id;
  final String message;
  final String username;
  final DateTime createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] ?? 0) as int,
      message: (json['message'] ?? '') as String,
      username: (json['username'] ?? json['user']?['username'] ?? 'Unknown') as String,
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
