class AuthToken {
  const AuthToken({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
    this.expiresIn,
  });

  final String accessToken;
  final String tokenType;
  final String? refreshToken;
  final int? expiresIn;

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: (json['access_token'] ?? '') as String,
      tokenType: (json['token_type'] ?? 'Bearer') as String,
      refreshToken: json['refresh_token'] as String?,
      expiresIn: json['expires_in'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
    };
  }
}
