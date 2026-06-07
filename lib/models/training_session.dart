class TrainingSession {
  final List<int> activityIds;
  final DateTime date;
  final String photoName;
  final String observations;

  const TrainingSession({
    required this.activityIds,
    required this.date,
    required this.photoName,
    required this.observations,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) => TrainingSession(
        activityIds: (json['activityIds'] as List<dynamic>)
            .map((id) => id as int)
            .toList(),
        date: DateTime.parse(json['date'] as String),
        photoName: json['photoName'] as String,
        observations: json['observations'] as String,
      );

  String get title => 'Sesión de entrenamiento';

  String get photoAssetPath => 'assets/people/$photoName';
}
