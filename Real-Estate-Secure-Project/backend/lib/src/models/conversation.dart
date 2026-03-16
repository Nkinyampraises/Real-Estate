import '../core/types.dart';
import 'entity.dart';

enum MessageType { text, image, file, offer, location, contact }

class ConversationSummary extends Entity implements JsonEncodable {
  const ConversationSummary({
    required super.id,
    required this.title,
    required this.lastMessage,
    required this.participants,
    required this.updatedAt,
  });

  final String title;
  final String lastMessage;
  final int participants;
  final DateTime updatedAt;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'last_message': lastMessage,
        'participants': participants,
        'updated_at': updatedAt.toIso8601String(),
      };
}

class MessageSummary extends Entity implements JsonEncodable {
  const MessageSummary({
    required super.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.sentAt,
  });

  final String conversationId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime sentAt;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'content': content,
        'type': type.name,
        'sent_at': sentAt.toIso8601String(),
      };
}
