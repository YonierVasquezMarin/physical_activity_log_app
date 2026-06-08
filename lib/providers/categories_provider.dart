import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:physical_activity_log_app/exceptions/api_exception.dart';
import 'package:physical_activity_log_app/models/category.dart';
import 'package:physical_activity_log_app/services/category_service.dart';

class CategoriesProvider extends ChangeNotifier {
  final CategoryService _categoryService;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoriesProvider({CategoryService? categoryService})
      : _categoryService = categoryService ?? CategoryService();

  List<Category> get categories => List.unmodifiable(_categories);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories({required String authorizationHeader}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await _categoryService.getCategories(
        authorizationHeader: authorizationHeader,
      );
      _categories = _sortCategories(loaded);
    } catch (error) {
      _error = resolveErrorMessage(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Category> createCategory({
    required String authorizationHeader,
    required String name,
    required String description,
  }) async {
    final category = await _categoryService.createCategory(
      authorizationHeader: authorizationHeader,
      name: name,
      description: description,
    );

    _categories = _sortCategories([..._categories, category]);
    notifyListeners();
    return category;
  }

  Future<Category> updateCategory({
    required String authorizationHeader,
    required int id,
    required String name,
    required String description,
  }) async {
    final category = await _categoryService.updateCategory(
      authorizationHeader: authorizationHeader,
      id: id,
      name: name,
      description: description,
    );

    _categories = _sortCategories(
      _categories
          .map((existing) => existing.id == id ? category : existing)
          .toList(),
    );
    notifyListeners();
    return category;
  }

  Future<void> deleteCategory({
    required String authorizationHeader,
    required int id,
  }) async {
    await _categoryService.deleteCategory(
      authorizationHeader: authorizationHeader,
      id: id,
    );

    _categories = _categories.where((category) => category.id != id).toList();
    notifyListeners();
  }

  List<Category> _sortCategories(List<Category> categories) {
    final sorted = List<Category>.from(categories);
    sorted.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return sorted;
  }

  String resolveErrorMessage(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Ocurrió un error inesperado. Intenta de nuevo.';
  }
}
