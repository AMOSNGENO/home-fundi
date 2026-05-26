import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String baseUrlOverride =
      String.fromEnvironment('HOMEFUNDI_API_URL', defaultValue: '');

  static String get baseUrl {
    if (baseUrlOverride.isNotEmpty) {
      return _normalizeBaseUrl(baseUrlOverride);
    }

    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api/v1';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:8000/api/v1';
    }
  }

  static String get apiVersion => '/api/v1';

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.endsWith('/') ? trimmed.substring(0, trimmed.length - 1) : trimmed;
  }
}