import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/report_summary.dart';
import 'package:physical_activity_log_app/services/reports_service.dart';

class ReportsProvider extends ChangeNotifier {
  final ReportsService _reportsService;

  ReportSummary? _summary;
  bool _isLoading = false;
  String? _error;
  DateTime? _fromDate;
  DateTime? _toDate;

  ReportsProvider({ReportsService? reportsService})
      : _reportsService = reportsService ?? ReportsService();

  ReportSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  Future<void> loadSummary({
    required String authorizationHeader,
    required DateTime from,
    required DateTime to,
    int topActivitiesLimit = 5,
  }) async {
    _isLoading = true;
    _error = null;
    _fromDate = from;
    _toDate = to;
    notifyListeners();

    try {
      _summary = await _reportsService.getSummary(
        authorizationHeader: authorizationHeader,
        from: from,
        to: to,
        topActivitiesLimit: topActivitiesLimit,
      );
    } catch (error) {
      _error = resolveErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String resolveErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
