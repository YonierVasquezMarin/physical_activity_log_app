import 'package:physical_activity_log_app/constants/api_constants.dart';
import 'package:physical_activity_log_app/dtos/category_request_dto.dart';
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

  Future<Category> createCategory({
    required String authorizationHeader,
    required String name,
    required String description,
  }) async {
    try {
      final json = await _httpService.post(
        ApiConstants.categories,
        headers: {'Authorization': authorizationHeader},
        body: CategoryRequestDto(name: name, description: description).toJson(),
      );

      return CategoryResponseDto.fromJson(json).toModel();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  Future<Category> updateCategory({
    required String authorizationHeader,
    required int id,
    required String name,
    required String description,
  }) async {
    try {
      final json = await _httpService.put(
        ApiConstants.category(id),
        headers: {'Authorization': authorizationHeader},
        body: CategoryRequestDto(name: name, description: description).toJson(),
      );

      return CategoryResponseDto.fromJson(json).toModel();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        message: 'No se pudo conectar con el servidor. Verifica tu conexión.',
      );
    }
  }

  Future<void> deleteCategory({
    required String authorizationHeader,
    required int id,
  }) async {
    try {
      await _httpService.delete(
        ApiConstants.category(id),
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
