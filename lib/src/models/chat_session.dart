import 'package:hive/hive.dart';
import 'chat_message.dart';

part 'chat_session.g.dart';

@HiveType(typeId: 0)
class ChatSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final List<ChatMessage> messages;

  @HiveField(3)
  bool isPinned;

  ChatSession({
    required this.id,
    List<ChatMessage>? messages,
    String? title,
    this.isPinned = false,
  })  : messages = messages ?? <ChatMessage>[],
        title = title ?? '';
}
