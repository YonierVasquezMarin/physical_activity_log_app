class TrainingSessionRequestDto {
  final List<int> activityIds;
  final String date;
  final String photoName;
  final String observations;

  const TrainingSessionRequestDto({
    required this.activityIds,
    required this.date,
    required this.photoName,
    required this.observations,
  });

  Map<String, dynamic> toJson() => {
        'activityIds': activityIds,
        'date': date,
        'photoName': photoName,
        'observations': observations,
      };
}
