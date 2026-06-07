class Activity {
  final int categoryId;
  final String name;
  final String description;

  const Activity({
    required this.categoryId,
    required this.name,
    required this.description,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        categoryId: json['categoryId'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
      );

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'name': name,
        'description': description,
      };
}
