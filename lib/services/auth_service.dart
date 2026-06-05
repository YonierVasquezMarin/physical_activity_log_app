import 'package:physical_activity_log_app/constants/api_constants.dart';
import 'package:physical_activity_log_app/dtos/login_request_dto.dart';
import 'package:physical_activity_log_app/dtos/login_response_dto.dart';
import 'package:physical_activity_log_app/dtos/register_request_dto.dart';
import 'package:physical_activity_log_app/dtos/user_response_dto.dart';
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/auth_session.dart';
import 'package:physical_activity_log_app/models/user.dart';
import 'package:physical_activity_log_app/services/http_service.dart';

class AuthService {
  final HttpService _httpService;

  AuthService({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  Future<User> register(RegisterRequestDto request) async {
    try {
      final json = await _httpService.post(
        ApiConstants.authRegister,
        body: request.toJson(),
      );
      return UserResponseDto.fromJson(json).toModel();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  Future<LoginResponseDto> login(LoginRequestDto request) async {
    try {
      final json = await _httpService.post(
        ApiConstants.authLogin,
        body: request.toJson(),
      );
      return LoginResponseDto.fromJson(json);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  Future<User> getCurrentUser(String authorizationHeader) async {
    try {
      final json = await _httpService.get(
        ApiConstants.authMe,
        headers: {'Authorization': authorizationHeader},
      );
      return UserResponseDto.fromJson(json).toModel();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  Future<AuthSession> loginAndFetchUser(LoginRequestDto request) async {
    final loginResponse = await login(request);
    final authorizationHeader =
        '${loginResponse.tokenType} ${loginResponse.token}';
    final user = await getCurrentUser(authorizationHeader);

    return AuthSession(
      token: loginResponse.token,
      tokenType: loginResponse.tokenType,
      expiresIn: loginResponse.expiresIn,
      user: user,
    );
  }
}
