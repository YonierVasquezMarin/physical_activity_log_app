class Activity {
  final int? id;
  final int categoryId;
  final String name;
  final String description;

  const Activity({
    this.id,
    required this.categoryId,
    required this.name,
    required this.description,
  });

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as int?,
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
