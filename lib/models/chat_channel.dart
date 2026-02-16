class ChatChannel {
  const ChatChannel({
    required this.id,
    required this.name,
    required this.slug,
    this.canDelete = false,
  });

  final int id;
  final String name;
  final String slug;
  final bool canDelete;

  factory ChatChannel.fromJson(Map<String, dynamic> json) {
    return ChatChannel(
      id: (json['id'] ?? 0) as int,
      name: (json['title'] ?? json['name'] ?? 'Unknown channel') as String,
      slug: (json['slug'] ?? '') as String,
      canDelete: (json['can_delete'] ?? false) as bool,
    );
  }
}
