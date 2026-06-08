import 'package:physical_activity_log_app/models/goal.dart';

class GoalResponseDto {
  final int id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;

  const GoalResponseDto({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  factory GoalResponseDto.fromJson(Map<String, dynamic> json) {
    return GoalResponseDto(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );
  }

  Goal toModel() => Goal(
        id: id,
        title: title,
        description: description,
        startDate: DateTime.parse(startDate),
        endDate: DateTime.parse(endDate),
      );
}
