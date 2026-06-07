import 'package:physical_activity_log_app/models/category.dart';

class CategoryResponseDto {
  final int id;
  final String name;
  final String description;

  const CategoryResponseDto({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CategoryResponseDto.fromJson(Map<String, dynamic> json) {
    return CategoryResponseDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Category toModel() => Category(
        id: id,
        name: name,
        description: description,
      );
}
