import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_token.dart';

class TokenStorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'discourse_auth_token';

  Future<void> saveToken(AuthToken token) async {
    await _storage.write(key: _tokenKey, value: jsonEncode(token.toJson()));
  }

  Future<AuthToken?> loadToken() async {
    final raw = await _storage.read(key: _tokenKey);
    if (raw == null || raw.isEmpty) return null;

    return AuthToken.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
