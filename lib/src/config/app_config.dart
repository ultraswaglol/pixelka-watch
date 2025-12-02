import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String _getDotEnv(String key) {
    if (kIsWeb) return '';
    return dotenv.env[key] ?? '';
  }

  static String _val(String fromEnv, String dotEnvKey,
      [String defaultVal = 'URL_NOT_FOUND']) {
    if (fromEnv.isNotEmpty) return fromEnv;
    final fromDotEnv = _getDotEnv(dotEnvKey);
    if (fromDotEnv.isNotEmpty) return fromDotEnv;
    return defaultVal;
  }

  static String get apiToken {
    const fromEnv = String.fromEnvironment('N8N_API_TOKEN');
    return _val(fromEnv, 'N8N_API_TOKEN', '');
  }

  static String get createUserUrl {
    const fromEnv = String.fromEnvironment('N8N_CREATE_USER_URL');
    return _val(fromEnv, 'N8N_CREATE_USER_URL');
  }

  static String get sttUrl {
    const fromEnv = String.fromEnvironment('N8N_STT_URL');
    return _val(fromEnv, 'N8N_STT_URL');
  }
}
