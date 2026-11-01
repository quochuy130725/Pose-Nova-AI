import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;

/// API Configuration for PoseNova AI Back-End.
/// Reads settings from `Front-end/.env` (and `--dart-define`) to avoid hardcoding.
/// Supports automatic host resolution across Windows/macOS/iOS (`localhost:3000`)
/// and Android Emulator (`10.0.2.2:3000`).
class ApiConfig {
  ApiConfig._();

  static const String _defaultApiPrefix = '/api/v1';
  static final Map<String, String> _env = {};
  static bool _isLoaded = false;

  /// Loads configuration from `Front-end/.env` asset
  static Future<void> loadEnv() async {
    if (_isLoaded) return;
    try {
      final envString = await rootBundle.loadString('.env');
      final lines = envString.split('\n');
      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        final eqIdx = line.indexOf('=');
        if (eqIdx != -1) {
          final key = line.substring(0, eqIdx).trim();
          var value = line.substring(eqIdx + 1).trim();
          if ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'"))) {
            value = value.substring(1, value.length - 1);
          }
          _env[key] = value;
        }
      }
      _isLoaded = true;

      // Update active base URL according to platform and .env
      _activeBaseUrl = _resolveInitialBaseUrl();
    } catch (_) {
      // Fallback if .env is missing or in mock testing
      _activeBaseUrl = _resolveInitialBaseUrl();
    }
  }

  static String get(String key, {String defaultValue = ''}) {
    return _env[key] ?? defaultValue;
  }

  static int get timeoutSeconds {
    final val = _env['API_TIMEOUT_SECONDS'];
    return int.tryParse(val ?? '') ?? 8;
  }

  static bool get enableOfflineFallback {
    final val = _env['ENABLE_OFFLINE_FALLBACK']?.toLowerCase();
    return val != 'false';
  }

  static String _resolveInitialBaseUrl() {
    // 1. First priority: compile-time --dart-define
    const dartDefineUrl = String.fromEnvironment('API_BASE_URL');
    if (dartDefineUrl.isNotEmpty) return dartDefineUrl;

    // 2. Second priority: platform-specific .env entries
    final envBaseUrl = _env['API_BASE_URL'];
    final envAndroidUrl = _env['API_BASE_URL_ANDROID'];

    if (!kIsWeb) {
      try {
        if (Platform.isAndroid && envAndroidUrl != null && envAndroidUrl.isNotEmpty) {
          return envAndroidUrl;
        }
      } catch (_) {}
    }

    if (envBaseUrl != null && envBaseUrl.isNotEmpty) {
      return envBaseUrl;
    }

    // 3. Fallback defaults
    return candidateBaseUrls.first;
  }

  /// Candidate base URLs ordered by priority for the current platform
  static List<String> get candidateBaseUrls {
    final envBaseUrl = _env['API_BASE_URL'] ?? 'http://localhost:3000$_defaultApiPrefix';
    final envLanUrl = _env['API_BASE_URL_LAN'] ?? 'http://192.168.137.1:3000$_defaultApiPrefix';
    final envAndroidUrl =
        _env['API_BASE_URL_ANDROID'] ?? 'http://10.0.2.2:3000$_defaultApiPrefix';

    if (kIsWeb) {
      return [envBaseUrl];
    }

    try {
      if (Platform.isAndroid) {
        return [
          envBaseUrl,
          envLanUrl,
          envAndroidUrl,
          'http://127.0.0.1:3000$_defaultApiPrefix',
        ];
      }
    } catch (_) {}

    return [
      envBaseUrl,
      'http://127.0.0.1:3000$_defaultApiPrefix',
    ];
  }

  static String _activeBaseUrl = candidateBaseUrls.first;

  static String get baseUrl => _activeBaseUrl;

  static void setActiveBaseUrl(String url) {
    _activeBaseUrl = url;
  }
}
