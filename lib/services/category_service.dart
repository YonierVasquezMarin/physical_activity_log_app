import 'package:physical_activity_log_app/constants/api_constants.dart';
import 'package:physical_activity_log_app/dtos/category_response_dto.dart';
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/category.dart';
import 'package:physical_activity_log_app/services/http_service.dart';

class CategoryService {
  final HttpService _httpService;

  CategoryService({HttpService? httpService})
      : _httpService = httpService ?? HttpService();

  Future<List<Category>> getCategories({
    required String authorizationHeader,
  }) async {
    try {
      final jsonList = await _httpService.getList(
        ApiConstants.categories,
        headers: {'Authorization': authorizationHeader},
      );

      return jsonList
          .map(
            (item) => CategoryResponseDto.fromJson(item as Map<String, dynamic>),
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
}
