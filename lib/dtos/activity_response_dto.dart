import 'package:physical_activity_log_app/models/activity.dart';

class ActivityResponseDto {
  final int id;
  final int categoryId;
  final String name;
  final String description;

  const ActivityResponseDto({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
  });

  factory ActivityResponseDto.fromJson(Map<String, dynamic> json) {
    return ActivityResponseDto(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Activity toModel() => Activity(
        id: id,
        categoryId: categoryId,
        name: name,
        description: description,
      );
}
