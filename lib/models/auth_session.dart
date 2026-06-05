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
}
