import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:uuid/uuid.dart';

import '../config.dart';
import '../models/auth_token.dart';

class DiscourseAuthService {
  final Dio _dio;

  DiscourseAuthService({Dio? dio}) : _dio = dio ?? Dio();

  /// Starts OAuth authorization code + PKCE flow.
  ///
  /// 1) Opens Discourse login in browser.
  /// 2) Receives redirect URL in the app.
  /// 3) Exchanges authorization code for access token.
  Future<AuthToken> loginWithDiscourse() async {
    final state = const Uuid().v4();
    final verifier = _generateCodeVerifier();
    final challenge = _buildCodeChallenge(verifier);

    final authUri = Uri.parse(AppConfig.authorizeUrl).replace(
      queryParameters: {
        'client_id': AppConfig.oauthClientId,
        'redirect_uri': AppConfig.oauthRedirectUri,
        'response_type': 'code',
        'scope': 'read write',
        'state': state,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
      },
    );

    final callbackUrl = await FlutterWebAuth2.authenticate(
      url: authUri.toString(),
      callbackUrlScheme: Uri.parse(AppConfig.oauthRedirectUri).scheme,
    );

    final callbackUri = Uri.parse(callbackUrl);
    if (callbackUri.queryParameters['state'] != state) {
      throw Exception('Invalid OAuth state, please try login again.');
    }

    final code = callbackUri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw Exception('Authorization code missing from callback.');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      AppConfig.tokenUrl,
      data: {
        'grant_type': 'authorization_code',
        'client_id': AppConfig.oauthClientId,
        'redirect_uri': AppConfig.oauthRedirectUri,
        'code_verifier': verifier,
        'code': code,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return AuthToken.fromJson(response.data ?? <String, dynamic>{});
  }

  String _generateCodeVerifier() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
    final random = Random.secure();
    return List<String>.generate(96, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _buildCodeChallenge(String verifier) {
    final digest = sha256.convert(ascii.encode(verifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}
