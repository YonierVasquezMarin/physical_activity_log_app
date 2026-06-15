import 'package:physical_activity_log_app/constants/api_constants.dart';
import 'package:physical_activity_log_app/dtos/report_summary_response_dto.dart';
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/report_summary.dart';
import 'package:physical_activity_log_app/services/http_service.dart';
import 'package:physical_activity_log_app/utils/date_formatter.dart';

class ReportsService {
  final HttpService _httpService;

  ReportsService({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  Future<ReportSummary> getSummary({
    required String authorizationHeader,
    required DateTime from,
    required DateTime to,
    int topActivitiesLimit = 5,
  }) async {
    try {
      final fromParam = formatDateUtcZ(from);
      final toParam = formatDateUtcZ(to);
      final url =
          '${ApiConstants.reportsSummary}?from=$fromParam&to=$toParam&topActivitiesLimit=$topActivitiesLimit';

      final json = await _httpService.get(
        url,
        headers: {'Authorization': authorizationHeader},
      );

      return ReportSummaryResponseDto.fromJson(json).toModel();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }
}
