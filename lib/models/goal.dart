class Goal {
  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  bool get isUpcoming => DateTime.now().isBefore(startDate);

  bool get isActive {
    final now = DateTime.now();
    return !now.isBefore(startDate) && !now.isAfter(endDate);
  }

  bool get isFinished => DateTime.now().isAfter(endDate);
}
