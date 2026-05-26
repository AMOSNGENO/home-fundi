import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage({SharedPreferences? preferences}) : _preferences = preferences;

  static const String accessTokenKey = 'homefundi.access_token';
  static const String refreshTokenKey = 'homefundi.refresh_token';
  static const String tokenTypeKey = 'homefundi.token_type';
  static const String profileKey = 'homefundi.profile';
  static const String expiresAtKey = 'homefundi.expires_at';

  final SharedPreferences? _preferences;

  Future<SharedPreferences> _prefs() async {
    return _preferences ?? await SharedPreferences.getInstance();
  }

  Future<String?> readAccessToken() async {
    final prefs = await _prefs();
    return prefs.getString(accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    final prefs = await _prefs();
    return prefs.getString(refreshTokenKey);
  }

  Future<String?> readTokenType() async {
    final prefs = await _prefs();
    return prefs.getString(tokenTypeKey);
  }

  Future<String?> readProfileJson() async {
    final prefs = await _prefs();
    return prefs.getString(profileKey);
  }

  Future<Map<String, dynamic>?> readProfile() async {
    final jsonValue = await readProfileJson();
    if (jsonValue == null || jsonValue.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonValue);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<DateTime?> readExpiresAt() async {
    final prefs = await _prefs();
    final raw = prefs.getString(expiresAtKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> saveSession({
    required String accessToken,
    String? refreshToken,
    String? tokenType,
    Map<String, dynamic>? profile,
    DateTime? expiresAt,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(refreshTokenKey, refreshToken);
    }
    if (tokenType != null) {
      await prefs.setString(tokenTypeKey, tokenType);
    }
    if (profile != null) {
      await prefs.setString(profileKey, jsonEncode(profile));
    }
    if (expiresAt != null) {
      await prefs.setString(expiresAtKey, expiresAt.toIso8601String());
    }
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    final prefs = await _prefs();
    await prefs.setString(profileKey, jsonEncode(profile));
  }

  Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    DateTime? expiresAt,
  }) async {
    final prefs = await _prefs();
    if (accessToken != null) {
      await prefs.setString(accessTokenKey, accessToken);
    }
    if (refreshToken != null) {
      await prefs.setString(refreshTokenKey, refreshToken);
    }
    if (tokenType != null) {
      await prefs.setString(tokenTypeKey, tokenType);
    }
    if (expiresAt != null) {
      await prefs.setString(expiresAtKey, expiresAt.toIso8601String());
    }
  }

  Future<void> clear() async {
    final prefs = await _prefs();
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
    await prefs.remove(tokenTypeKey);
    await prefs.remove(profileKey);
    await prefs.remove(expiresAtKey);
  }
}
