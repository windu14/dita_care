class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final bool isSaved;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.isSaved = false,
  });

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    bool? isSaved,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
