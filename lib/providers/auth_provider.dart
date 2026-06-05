import 'package:flutter/foundation.dart';
import 'package:physical_activity_log_app/dtos/login_request_dto.dart';
import 'package:physical_activity_log_app/dtos/register_request_dto.dart';
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/auth_session.dart';
import 'package:physical_activity_log_app/models/user.dart';
import 'package:physical_activity_log_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthSession? _session;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  String? get token => _session?.token;
  String? get tokenType => _session?.tokenType;
  int? get expiresIn => _session?.expiresIn;
  User? get user => _session?.user;
  bool get isAuthenticated => _session != null;
  String? get authorizationHeader => _session?.authorizationHeader;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final session = await _authService.loginAndFetchUser(
      LoginRequestDto(email: email.trim(), password: password),
    );
    _session = session;
    notifyListeners();
  }

  Future<void> registerAndLogin({
    required String name,
    required String email,
    required String password,
  }) async {
    await _authService.register(
      RegisterRequestDto(
        name: name.trim(),
        email: email.trim(),
        password: password,
      ),
    );

    final session = await _authService.loginAndFetchUser(
      LoginRequestDto(email: email.trim(), password: password),
    );
    _session = session;
    notifyListeners();
  }

  void logout() {
    _session = null;
    notifyListeners();
  }

  String resolveErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
