import 'package:physical_activity_log_app/constants/api_constants.dart';
import 'package:physical_activity_log_app/dtos/create_activity_request_dto.dart';
import 'package:physical_activity_log_app/dtos/training_session_request_dto.dart';
import 'package:physical_activity_log_app/dtos/training_session_response_dto.dart';
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/activity.dart';
import 'package:physical_activity_log_app/models/training_session.dart';
import 'package:physical_activity_log_app/services/activity_service.dart';
import 'package:physical_activity_log_app/services/http_service.dart';
import 'package:physical_activity_log_app/utils/date_formatter.dart';
import 'package:physical_activity_log_app/utils/training_session_photo_picker.dart';

class TrainingSessionService {
  final HttpService _httpService;
  final ActivityService _activityService;

  TrainingSessionService({
    HttpService? httpService,
    ActivityService? activityService,
  })  : _httpService = httpService ?? HttpService(),
        _activityService = activityService ?? ActivityService();

  Future<List<TrainingSession>> getTrainingSessions({
    required String authorizationHeader,
  }) async {
    try {
      final jsonList = await _httpService.getList(
        ApiConstants.trainingSessions,
        headers: {'Authorization': authorizationHeader},
      );

      return jsonList
          .map(
            (item) =>
                TrainingSessionResponseDto.fromJson(item as Map<String, dynamic>),
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

  Future<TrainingSession> createTrainingSession({
    required String authorizationHeader,
    required List<Activity> activities,
    required DateTime date,
    required String observations,
  }) async {
    try {
      final activityIds = await _createActivities(
        authorizationHeader: authorizationHeader,
        activities: activities,
      );

      final existingSessions = await getTrainingSessions(
        authorizationHeader: authorizationHeader,
      );
      final photoName = pickTrainingSessionPhoto(existingSessions);

      final json = await _httpService.post(
        ApiConstants.trainingSessions,
        headers: {'Authorization': authorizationHeader},
        body: TrainingSessionRequestDto(
          activityIds: activityIds,
          date: formatDateWithOffset(date),
          photoName: photoName,
          observations: observations,
        ).toJson(),
      );

      return TrainingSessionResponseDto.fromJson(json).toModel();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  Future<TrainingSession> updateTrainingSession({
    required String authorizationHeader,
    required int id,
    required List<Activity> activities,
    required DateTime date,
    required String photoName,
    required String observations,
  }) async {
    try {
      final activityIds = await _createActivities(
        authorizationHeader: authorizationHeader,
        activities: activities,
      );

      final json = await _httpService.put(
        ApiConstants.trainingSession(id),
        headers: {'Authorization': authorizationHeader},
        body: TrainingSessionRequestDto(
          activityIds: activityIds,
          date: formatDateWithOffset(date),
          photoName: photoName,
          observations: observations,
        ).toJson(),
      );

      return TrainingSessionResponseDto.fromJson(json).toModel();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  Future<void> deleteTrainingSession({
    required String authorizationHeader,
    required int id,
  }) async {
    try {
      await _httpService.delete(
        ApiConstants.trainingSession(id),
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

  Future<List<int>> _createActivities({
    required String authorizationHeader,
    required List<Activity> activities,
  }) async {
    final activityIds = <int>[];

    for (final activity in activities) {
      final createdActivity = await _activityService.createActivity(
        authorizationHeader: authorizationHeader,
        request: CreateActivityRequestDto(
          categoryId: activity.categoryId,
          name: activity.name,
          description: activity.description,
        ),
      );
      activityIds.add(createdActivity.id!);
    }

    return activityIds;
  }
}
