import 'dart:async';
import 'package:flutter/material.dart';

import '../data/services/stt_service.dart';
import '../models/chat_message.dart';
import '../providers/chat_session_service.dart';

class ChatMessageService extends ChangeNotifier {
  final ChatSessionService _sessionService;
  final SttService _sttService;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  ChatMessageService(this._sessionService, this._sttService);

  void _setTyping(bool typing) {
    if (_isTyping == typing) return;
    _isTyping = typing;
    notifyListeners();
  }

  Future<void> sendVoiceMessage(String path) async {
    final chat = _sessionService.currentChat;
    if (chat == null) return;

    _setTyping(true);

    try {
      final userId = _sessionService.authService.userId ?? "watch_user";

      final response =
          await _sttService.getTranscriptionAndResponse(path, userId);

      if (response == null) {
        throw Exception("Server connection failed");
      }

      final transcription = response['transcription'] ?? '';
      if (transcription.isNotEmpty) {
        _addMessageToChat(ChatMessage(
            type: MessageType.text,
            text: transcription,
            isUserMessage: true,
            timestamp: DateTime.now()));
      }

      final aiResponse = response['output'];

      if (response['imageUrl'] != null || response['fileUrl'] != null) {
        _addMessageToChat(ChatMessage(
            type: MessageType.text,
            text: "[Изображение или файл]. Посмотри на телефоне.",
            isUserMessage: false,
            timestamp: DateTime.now()));
      } else if (aiResponse != null && aiResponse.isNotEmpty) {
        _addMessageToChat(ChatMessage(
          type: MessageType.text,
          text: aiResponse,
          isUserMessage: false,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      debugPrint("Voice Error: $e");
      _addMessageToChat(ChatMessage(
          type: MessageType.text,
          text: "Ошибка: $e",
          isUserMessage: false,
          timestamp: DateTime.now()));
    } finally {
      _setTyping(false);
    }
  }

  void _addMessageToChat(ChatMessage message) {
    final chat = _sessionService.currentChat;
    if (chat == null) return;

    chat.messages.add(message);
    chat.save();
    _sessionService.notifyListeners();
  }
}
