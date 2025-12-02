import 'dart:convert';
import 'package:pixelka_watch/src/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _uuid = const Uuid();

  static const _keyUserId = 'user_id';
  static const _keyConnectionCode = 'connection_code';
  static const _keyTermsAccepted = 'terms_accepted';

  final String _n8nCreateUserUrl = AppConfig.createUserUrl;
  final String _apiToken = AppConfig.apiToken;

  String? _userId;
  String? _connectionCode;
  bool _isLoading = true;
  bool _isConnectionCodeLoading = false;
  bool _hasAcceptedTerms = false;

  String? get userId => _userId;
  String? get connectionCode => _connectionCode;
  bool get isLoading => _isLoading;
  bool get isConnectionCodeLoading => _isConnectionCodeLoading;
  bool get hasAcceptedTerms => _hasAcceptedTerms;

  AuthService() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    _userId = await _storage.read(key: _keyUserId);
    bool isNewUser = false;
    if (_userId == null) {
      final newUserId = _uuid.v4();
      await _storage.write(key: _keyUserId, value: newUserId);
      _userId = newUserId;
      isNewUser = true;
      debugPrint("AuthService: Created new user ID: $_userId");
    } else {
      debugPrint("AuthService: Loaded existing user ID: $_userId");
    }

    final termsAcceptedString = await _storage.read(key: _keyTermsAccepted);
    _hasAcceptedTerms = (termsAcceptedString == 'true');
    debugPrint("AuthService: Has accepted terms: $_hasAcceptedTerms");

    _connectionCode = await _storage.read(key: _keyConnectionCode);
    if (isNewUser || _connectionCode == null) {
      debugPrint("AuthService: Fetching new connection code...");
      try {
        await _fetchAndSaveConnectionCode();
      } finally {}
    } else {
      debugPrint("AuthService: Loaded cached connection code.");
    }

    _isLoading = false;
    notifyListeners();
    debugPrint("AuthService: Initial data loading complete.");
  }

  Future<void> _fetchAndSaveConnectionCode() async {
    if (_userId == null) return;

    String? newCode;
    if (_n8nCreateUserUrl == 'URL_NOT_FOUND') {
      newCode = "DEMO-123-XYZ";
      debugPrint("ATTENTION: N8N vars not found. Using demo code.");
    } else {
      try {
        final response = await http.post(
          Uri.parse(_n8nCreateUserUrl),
          headers: {
            'Content-Type': 'application/json',
            if (_apiToken.isNotEmpty) 'Authorization': _apiToken,
          },
          body: json.encode({'userId': _userId}),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          newCode = data['connection_code'];
          debugPrint("AuthService: Fetched connection code: $newCode");
        } else {
          newCode = "Ошибка: ${response.statusCode}";
          debugPrint(
              "AuthService: Error fetching connection code: ${response.statusCode}");
        }
      } catch (e) {
        newCode = "Ошибка сети";
        debugPrint("AuthService: Network error fetching connection code: $e");
      }
    }

    _connectionCode = newCode;
    if (_connectionCode != null) {
      await _storage.write(key: _keyConnectionCode, value: _connectionCode);
      debugPrint("AuthService: Saved connection code.");
    }
  }

  Future<void> refreshConnectionCode() async {
    _isConnectionCodeLoading = true;
    notifyListeners();

    try {
      await _fetchAndSaveConnectionCode();
    } finally {
      _isConnectionCodeLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptTerms() async {
    if (_hasAcceptedTerms) return;
    _hasAcceptedTerms = true;
    await _storage.write(key: _keyTermsAccepted, value: 'true');
    debugPrint("AuthService: Terms accepted and saved.");
    notifyListeners();
  }
}
