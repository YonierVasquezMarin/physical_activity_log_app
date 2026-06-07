import 'package:physical_activity_log_app/constants/api_constants.dart';
import 'package:physical_activity_log_app/dtos/activity_response_dto.dart';
import 'package:physical_activity_log_app/dtos/create_activity_request_dto.dart';
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/activity.dart';
import 'package:physical_activity_log_app/services/http_service.dart';

class ActivityService {
  final HttpService _httpService;

  ActivityService({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  Future<Activity> createActivity({
    required String authorizationHeader,
    required CreateActivityRequestDto request,
  }) async {
    try {
      final json = await _httpService.post(
        ApiConstants.activities,
        headers: {'Authorization': authorizationHeader},
        body: request.toJson(),
      );

      return ActivityResponseDto.fromJson(json).toModel();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }
}
