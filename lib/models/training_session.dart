import 'package:physical_activity_log_app/models/activity.dart';

class TrainingSession {
  final List<Activity> activities;
  final DateTime date;
  final String photoName;
  final String observations;

  const TrainingSession({
    required this.activities,
    required this.date,
    required this.photoName,
    required this.observations,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      TrainingSession(
        activities: (json['activities'] as List<dynamic>)
            .map((item) => Activity.fromJson(item as Map<String, dynamic>))
            .toList(),
        date: DateTime.parse(json['date'] as String),
        photoName: json['photoName'] as String,
        observations: json['observations'] as String,
      );

  String get title => 'Sesión de entrenamiento';

  String get photoAssetPath => 'assets/people/$photoName';
}
