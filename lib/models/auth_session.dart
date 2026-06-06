import 'package:physical_activity_log_app/models/user.dart';

class AuthSession {
  final String token;
  final String tokenType;
  final int expiresIn;
  final User user;

  const AuthSession({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  String get authorizationHeader => '$tokenType $token';

  Map<String, dynamic> toJson() => {
        'token': token,
        'tokenType': tokenType,
        'expiresIn': expiresIn,
        'user': user.toJson(),
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: json['token'] as String,
        tokenType: json['tokenType'] as String,
        expiresIn: json['expiresIn'] as int,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );
}
