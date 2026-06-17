enum MessageRole { user, model }

class ChatMessage {
  final MessageRole role;
  final String text; // For user: instruction. For model: the parsed <narrative_generation>
  final String? rawXml; // For model: store the full raw XML response

  ChatMessage({
    required this.role,
    required this.text,
    this.rawXml,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.model,
      text: json['text'] ?? '',
      rawXml: json['rawXml'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role == MessageRole.user ? 'user' : 'model',
      'text': text,
      'rawXml': rawXml,
    };
  }
}
