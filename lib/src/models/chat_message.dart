import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 2)
enum MessageType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  generatedImage,
  @HiveField(3)
  file,
}

@HiveType(typeId: 1)
class ChatMessage {
  @HiveField(0)
  final String text;
  @HiveField(1)
  final bool isUserMessage;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? htmlContent;

  @HiveField(4)
  final MessageType type;

  @HiveField(5)
  final String? imagePath;

  @HiveField(6)
  final String? audioPath;

  @HiveField(7)
  final String? generatedImageUrl;

  @HiveField(8)
  final String? fileUrl;

  @HiveField(9)
  final String? fileName;

  ChatMessage({
    this.text = '',
    required this.isUserMessage,
    required this.timestamp,
    this.htmlContent,
    this.type = MessageType.text,
    this.imagePath,
    this.audioPath,
    this.generatedImageUrl,
    this.fileUrl,
    this.fileName,
  });
}
