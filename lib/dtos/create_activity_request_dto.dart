class CreateActivityRequestDto {
  final int categoryId;
  final String name;
  final String description;

  const CreateActivityRequestDto({
    required this.categoryId,
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'name': name,
        'description': description,
      };
}
