import 'package:flutter/foundation.dart';
import 'package:physical_activity_log_app/dtos/login_request_dto.dart';
import 'package:physical_activity_log_app/dtos/register_request_dto.dart';
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/auth_session.dart';
import 'package:physical_activity_log_app/models/user.dart';
import 'package:physical_activity_log_app/services/auth_service.dart';
import 'package:physical_activity_log_app/services/session_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final SessionStorageService _sessionStorage;

  AuthSession? _session;

  AuthProvider({
    AuthService? authService,
    SessionStorageService? sessionStorage,
  })  : _authService = authService ?? AuthService(),
        _sessionStorage = sessionStorage ?? SessionStorageService();

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
    await _sessionStorage.saveSession(session);
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
    await _sessionStorage.saveSession(session);
    notifyListeners();
  }

  Future<bool> tryRestoreSession() async {
    final storedSession = await _sessionStorage.loadSession();
    if (storedSession == null) {
      return false;
    }

    _session = storedSession;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _session = null;
    await _sessionStorage.clearSession();
    notifyListeners();
  }

  String resolveErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
