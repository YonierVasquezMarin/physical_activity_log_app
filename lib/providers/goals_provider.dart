import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/goal.dart';
import 'package:physical_activity_log_app/services/goal_service.dart';

class GoalsProvider extends ChangeNotifier {
  final GoalService _goalService;

  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  GoalsProvider({GoalService? goalService})
      : _goalService = goalService ?? GoalService();

  List<Goal> get goals => List.unmodifiable(_goals);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGoals({required String authorizationHeader}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await _goalService.getGoals(
        authorizationHeader: authorizationHeader,
      );
      _goals = _sortGoals(loaded);
    } catch (error) {
      _error = resolveErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Goal> createGoal({
    required String authorizationHeader,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final goal = await _goalService.createGoal(
      authorizationHeader: authorizationHeader,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
    );

    _goals = _sortGoals([..._goals, goal]);
    notifyListeners();
    return goal;
  }

  Future<Goal> updateGoal({
    required String authorizationHeader,
    required int id,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final goal = await _goalService.updateGoal(
      authorizationHeader: authorizationHeader,
      id: id,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
    );

    _goals = _sortGoals(
      _goals.map((existing) => existing.id == id ? goal : existing).toList(),
    );
    notifyListeners();
    return goal;
  }

  Future<void> deleteGoal({
    required String authorizationHeader,
    required int id,
  }) async {
    await _goalService.deleteGoal(
      authorizationHeader: authorizationHeader,
      id: id,
    );

    _goals = _goals.where((goal) => goal.id != id).toList();
    notifyListeners();
  }

  List<Goal> _sortGoals(List<Goal> goals) {
    final sorted = List<Goal>.from(goals);
    sorted.sort((a, b) => b.startDate.compareTo(a.startDate));
    return sorted;
  }

  String resolveErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
