import 'package:flutter/material.dart';

import '../models/auth_token.dart';
import '../services/token_storage_service.dart';
import 'discourse_auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required DiscourseAuthService authService,
    required TokenStorageService storageService,
  })  : _authService = authService,
        _storageService = storageService;

  final DiscourseAuthService _authService;
  final TokenStorageService _storageService;

  AuthToken? _token;
  bool _loading = false;
  String? _error;

  AuthToken? get token => _token;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _token != null;

  Future<void> initialize() async {
    _loading = true;
    notifyListeners();

    try {
      _token = await _storageService.loadToken();
      _error = null;
    } catch (e) {
      _error = 'Failed to restore previous session: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> login() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _token = await _authService.loginWithDiscourse();
      await _storageService.saveToken(_token!);
    } catch (e) {
      _error = 'Login failed: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _error = null;
    await _storageService.clearToken();
    notifyListeners();
  }
}
