import 'package:physical_activity_log_app/constants/api_constants.dart';
import 'package:physical_activity_log_app/dtos/goal_request_dto.dart';
import 'package:physical_activity_log_app/dtos/goal_response_dto.dart';
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/goal.dart';
import 'package:physical_activity_log_app/services/http_service.dart';
import 'package:physical_activity_log_app/utils/date_formatter.dart';

class GoalService {
  final HttpService _httpService;

  GoalService({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  Future<List<Goal>> getGoals({
    required String authorizationHeader,
  }) async {
    try {
      final jsonList = await _httpService.getList(
        ApiConstants.goals,
        headers: {'Authorization': authorizationHeader},
      );

      return jsonList
          .map(
            (item) => GoalResponseDto.fromJson(item as Map<String, dynamic>),
          )
          .map((dto) => dto.toModel())
          .toList();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  Future<Goal> getGoal({
    required String authorizationHeader,
    required int id,
  }) async {
    try {
      final json = await _httpService.get(
        ApiConstants.goal(id),
        headers: {'Authorization': authorizationHeader},
      );

      return GoalResponseDto.fromJson(json).toModel();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  Future<Goal> createGoal({
    required String authorizationHeader,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final json = await _httpService.post(
        ApiConstants.goals,
        headers: {'Authorization': authorizationHeader},
        body: GoalRequestDto(
          title: title,
          description: description,
          startDate: formatDateWithOffset(startDate),
          endDate: formatDateWithOffset(endDate),
        ).toJson(),
      );

      return GoalResponseDto.fromJson(json).toModel();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  Future<Goal> updateGoal({
    required String authorizationHeader,
    required int id,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final json = await _httpService.put(
        ApiConstants.goal(id),
        headers: {'Authorization': authorizationHeader},
        body: GoalRequestDto(
          title: title,
          description: description,
          startDate: formatDateWithOffset(startDate),
          endDate: formatDateWithOffset(endDate),
        ).toJson(),
      );

      return GoalResponseDto.fromJson(json).toModel();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  Future<void> deleteGoal({
    required String authorizationHeader,
    required int id,
  }) async {
    try {
      await _httpService.delete(
        ApiConstants.goal(id),
        headers: {'Authorization': authorizationHeader},
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }
}
