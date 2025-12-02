import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum ResponseMode { text, voice }

enum ChatLayoutStyle { messenger, fullWidth }

class SettingsService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  static const _keyResponseMode = 'response_mode';
  static const _keyThemeMode = 'theme_mode';
  static const _keyLocale = 'locale';
  static const _keyChatLayoutStyle = 'chat_layout_style';

  ResponseMode _responseMode = ResponseMode.text;
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  bool _isLoading = true;
  ChatLayoutStyle _chatLayoutStyle = ChatLayoutStyle.messenger;

  ResponseMode get responseMode => _responseMode;
  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  bool get isLoading => _isLoading;
  ChatLayoutStyle get chatLayoutStyle => _chatLayoutStyle;

  SettingsService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final responseModeString = await _storage.read(key: _keyResponseMode);
      if (responseModeString == 'voice') {
        _responseMode = ResponseMode.voice;
      } else {
        _responseMode = ResponseMode.text;
      }

      final themeModeString = await _storage.read(key: _keyThemeMode);
      switch (themeModeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
          break;
      }

      final localeString = await _storage.read(key: _keyLocale);
      if (localeString != null && localeString.isNotEmpty) {
        _locale = Locale(localeString);
      } else {
        _locale = null;
      }

      final styleString = await _storage.read(key: _keyChatLayoutStyle);
      if (styleString == 'fullWidth') {
        _chatLayoutStyle = ChatLayoutStyle.fullWidth;
      } else {
        _chatLayoutStyle = ChatLayoutStyle.messenger;
      }
    } catch (e) {
      debugPrint("Error loading settings: $e");
      _responseMode = ResponseMode.text;
      _themeMode = ThemeMode.system;
      _locale = null;
      _chatLayoutStyle = ChatLayoutStyle.messenger;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setResponseMode(ResponseMode mode) async {
    if (_responseMode == mode) return;
    _responseMode = mode;
    await _storage.write(key: _keyResponseMode, value: mode.name);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _storage.write(key: _keyThemeMode, value: mode.name);
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _storage.write(key: _keyLocale, value: locale?.languageCode ?? '');
    notifyListeners();
  }

  Future<void> setChatLayoutStyle(ChatLayoutStyle style) async {
    if (_chatLayoutStyle == style) return;
    _chatLayoutStyle = style;
    await _storage.write(key: _keyChatLayoutStyle, value: style.name);
    notifyListeners();
  }
}
