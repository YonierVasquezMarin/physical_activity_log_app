class GoalRequestDto {
  final String title;
  final String description;
  final String startDate;
  final String endDate;

  const GoalRequestDto({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
      };
}
