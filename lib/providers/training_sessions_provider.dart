import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/activity.dart';
import 'package:physical_activity_log_app/models/category.dart';
import 'package:physical_activity_log_app/models/training_session.dart';
import 'package:physical_activity_log_app/services/category_service.dart';
import 'package:physical_activity_log_app/services/training_session_service.dart';

class TrainingSessionsProvider extends ChangeNotifier {
  final TrainingSessionService _trainingSessionService;
  final CategoryService _categoryService;

  List<TrainingSession> _sessions = [];
  List<Category> _categories = [];
  bool _isLoadingSessions = false;
  bool _isLoadingCategories = false;
  String? _sessionsError;

  TrainingSessionsProvider({
    TrainingSessionService? trainingSessionService,
    CategoryService? categoryService,
  })  : _trainingSessionService =
            trainingSessionService ?? TrainingSessionService(),
        _categoryService = categoryService ?? CategoryService();

  List<TrainingSession> get sessions => List.unmodifiable(_sessions);
  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoadingSessions => _isLoadingSessions;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get sessionsError => _sessionsError;

  Future<void> loadSessions({required String authorizationHeader}) async {
    _isLoadingSessions = true;
    _sessionsError = null;
    notifyListeners();

    try {
      _sessions = await _trainingSessionService.getTrainingSessions(
        authorizationHeader: authorizationHeader,
      );
    } catch (error) {
      _sessionsError = resolveErrorMessage(error);
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories({required String authorizationHeader}) async {
    if (_categories.isNotEmpty || _isLoadingCategories) {
      return;
    }

    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories(
        authorizationHeader: authorizationHeader,
      );
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  void syncCategories(List<Category> categories) {
    _categories = List<Category>.from(categories);
    notifyListeners();
  }

  Future<TrainingSession> createSession({
    required String authorizationHeader,
    required List<Activity> activities,
    required DateTime date,
    required String observations,
  }) async {
    final session = await _trainingSessionService.createTrainingSession(
      authorizationHeader: authorizationHeader,
      activities: activities,
      date: date,
      observations: observations,
    );

    _sessions = [session, ..._sessions];
    notifyListeners();
    return session;
  }

  Future<TrainingSession> updateSession({
    required String authorizationHeader,
    required int id,
    required List<Activity> activities,
    required DateTime date,
    required String photoName,
    required String observations,
  }) async {
    final session = await _trainingSessionService.updateTrainingSession(
      authorizationHeader: authorizationHeader,
      id: id,
      activities: activities,
      date: date,
      photoName: photoName,
      observations: observations,
    );

    _sessions = _sessions
        .map((existing) => existing.id == id ? session : existing)
        .toList();
    notifyListeners();
    return session;
  }

  Future<void> deleteSession({
    required String authorizationHeader,
    required int id,
  }) async {
    await _trainingSessionService.deleteTrainingSession(
      authorizationHeader: authorizationHeader,
      id: id,
    );

    _sessions = _sessions.where((session) => session.id != id).toList();
    notifyListeners();
  }

  String resolveErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
