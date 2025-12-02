import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../data/services/auth_service.dart';
import '../models/chat_session.dart';

class ChatSessionService extends ChangeNotifier {
  final AuthService authService;
  Box<ChatSession>? _chatBox;
  List<ChatSession> _chatSessions = [];
  String? _selectedChatId;
  bool _isLoading = true;
  bool _mounted = true;

  List<ChatSession> get chatSessions => _chatSessions;
  String? get selectedChatId => _selectedChatId;
  bool get isLoading => _isLoading;

  ChatSession? get currentChat {
    if (_selectedChatId == null || _chatSessions.isEmpty) return null;
    try {
      return _chatSessions.firstWhere((c) => c.id == _selectedChatId);
    } catch (e) {
      return null;
    }
  }

  ChatSessionService(this.authService) {
    authService.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  void initializeForWatch() {
    if (_chatSessions.isEmpty) {
      createNewChat();
    } else {
      selectChat(_chatSessions.first.id);
    }
  }

  void _onAuthChanged() async {
    if (!_isLoading) {
      _isLoading = true;
      if (_mounted) notifyListeners();
    }

    final userId = authService.userId;
    if (_chatBox != null && _chatBox!.name != 'watch_sessions_$userId') {
      await _chatBox?.close();
      _chatBox = null;
      _chatSessions = [];
      _selectedChatId = null;
    }

    try {
      if (userId != null && (_chatBox == null || !_chatBox!.isOpen)) {
        _chatBox = await Hive.openBox<ChatSession>('watch_sessions_$userId');
        _loadChats();
      }
    } catch (e) {
      debugPrint("🔴 HIVE ERROR: $e");
      if (userId != null) {
        await Hive.deleteBoxFromDisk('watch_sessions_$userId');
        _chatBox = await Hive.openBox<ChatSession>('watch_sessions_$userId');
        _loadChats();
      }
    } finally {
      _isLoading = false;
      if (_mounted) notifyListeners();
    }
  }

  void _loadChats() {
    if (_chatBox == null || !_chatBox!.isOpen) return;
    try {
      _chatSessions = _chatBox!.values.toList();
    } catch (e) {
      _chatSessions = [];
      _chatBox!.clear();
    }
    _sortSessions();
    if (_mounted) notifyListeners();
  }

  void _sortSessions() {
    _chatSessions.sort((a, b) {
      final aTime =
          a.messages.isNotEmpty ? a.messages.last.timestamp : DateTime(1970);
      final bTime =
          b.messages.isNotEmpty ? b.messages.last.timestamp : DateTime(1970);
      return bTime.compareTo(aTime);
    });
  }

  void createNewChat() {
    if (_chatBox == null || !_chatBox!.isOpen) return;
    final newChat = ChatSession(id: const Uuid().v4(), title: "Watch Chat");
    _chatBox!.put(newChat.id, newChat);
    _chatSessions.insert(0, newChat);
    selectChat(newChat.id);
  }

  void selectChat(String id) {
    if (_selectedChatId != id) {
      _selectedChatId = id;
      if (_mounted) notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    authService.removeListener(_onAuthChanged);
    super.dispose();
  }
}
