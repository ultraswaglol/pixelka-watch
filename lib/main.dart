import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wear/wear.dart';

import 'src/models/chat_session.dart';
import 'src/models/chat_message.dart';
import 'src/data/services/auth_service.dart';
import 'src/data/services/stt_service.dart';
import 'src/data/services/settings_service.dart';
import 'src/providers/chat_session_service.dart';
import 'src/providers/chat_message_service.dart';
import 'src/services/audio_recording_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Error loading .env: $e");
  }

  await Hive.initFlutter();
  Hive.registerAdapter(ChatSessionAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(MessageTypeAdapter());

  runApp(const WearMyApp());
}

class WearMyApp extends StatelessWidget {
  const WearMyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => SttService()),
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProxyProvider<AuthService, ChatSessionService>(
          create: (context) => ChatSessionService(context.read<AuthService>()),
          update: (context, auth, prev) => prev!,
        ),
        ChangeNotifierProxyProvider2<ChatSessionService, SttService,
            ChatMessageService>(
          create: (context) => ChatMessageService(
            context.read<ChatSessionService>(),
            context.read<SttService>(),
          ),
          update: (context, session, stt, prev) => prev!,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF7C4DFF),
            surface: Color(0xFF1E1E1E),
            onSurface: Colors.white,
          ),
        ),
        home: const WatchChatScreen(),
      ),
    );
  }
}

class WatchChatScreen extends StatefulWidget {
  const WatchChatScreen({super.key});

  @override
  State<WatchChatScreen> createState() => _WatchChatScreenState();
}

class _WatchChatScreenState extends State<WatchChatScreen> {
  final AudioRecordingService _audioService = AudioRecordingService();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<ChatSessionService>();
      Future.delayed(const Duration(milliseconds: 200), () {
        session.initializeForWatch();
      });
    });
  }

  Future<void> _toggleRecording() async {
    final msgService = context.read<ChatMessageService>();

    if (_isRecording) {
      // Стоп
      final path = await _audioService.stopRecording();
      setState(() {
        _isRecording = false;
      });
      if (path != null && mounted) {
        msgService.sendVoiceMessage(path);
        _scrollToBottom();
      }
    } else {
      // Старт
      final hasPerm = await _audioService.requestPermission();
      if (hasPerm) {
        await _audioService.startRecording();
        setState(() {
          _isRecording = true;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (BuildContext context, WearShape shape, Widget? child) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Consumer<ChatSessionService>(
                  builder: (context, session, _) {
                    if (session.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages =
                        session.currentChat?.messages.reversed.toList() ?? [];

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mic_none_rounded,
                                size: 32, color: Colors.grey.shade800),
                            const SizedBox(height: 4),
                            Text("Нажми чтобы сказать",
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 90),
                      itemCount: messages.length,
                      itemBuilder: (ctx, i) {
                        final msg = messages[i];
                        return _buildMessageCard(msg);
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 80,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black,
                        Colors.black.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Consumer<ChatMessageService>(
                      builder: (context, msgService, _) {
                        if (msgService.isTyping) {
                          return const SizedBox(
                            width: 54,
                            height: 54,
                            child: CircularProgressIndicator(
                                strokeWidth: 3, color: Color(0xFF7C4DFF)),
                          );
                        }

                        return GestureDetector(
                          onTap: _toggleRecording,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _isRecording ? 60 : 54,
                            height: _isRecording ? 60 : 54,
                            decoration: BoxDecoration(
                              color: _isRecording
                                  ? Colors.redAccent
                                  : const Color(0xFF7C4DFF),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (_isRecording
                                          ? Colors.red
                                          : const Color(0xFF7C4DFF))
                                      .withValues(alpha: 0.4), // Исправлено
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: Icon(
                              _isRecording
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageCard(ChatMessage msg) {
    if (msg.isUserMessage) {
      return Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 12, right: 4),
          child: Text(
            msg.text,
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontStyle: FontStyle.italic),
            textAlign: TextAlign.right,
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          msg.text,
          style: const TextStyle(
              fontSize: 13, color: Color(0xFFE0E0E0), height: 1.3),
        ),
      );
    }
  }
}
