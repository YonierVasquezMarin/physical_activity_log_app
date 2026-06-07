import 'package:physical_activity_log_app/dtos/activity_response_dto.dart';
import 'package:physical_activity_log_app/models/training_session.dart';

class TrainingSessionResponseDto {
  final int id;
  final List<ActivityResponseDto> activities;
  final String date;
  final String photoName;
  final String observations;

  const TrainingSessionResponseDto({
    required this.id,
    required this.activities,
    required this.date,
    required this.photoName,
    required this.observations,
  });

  factory TrainingSessionResponseDto.fromJson(Map<String, dynamic> json) {
    return TrainingSessionResponseDto(
      id: json['id'] as int,
      activities: (json['activities'] as List<dynamic>)
          .map(
            (item) => ActivityResponseDto.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      date: json['date'] as String,
      photoName: json['photoName'] as String,
      observations: json['observations'] as String,
    );
  }

  TrainingSession toModel() => TrainingSession(
        id: id,
        activities: activities.map((activity) => activity.toModel()).toList(),
        date: DateTime.parse(date),
        photoName: photoName,
        observations: observations,
      );
}
