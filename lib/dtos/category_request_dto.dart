class CategoryRequestDto {
  final String name;
  final String description;

  const CategoryRequestDto({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}
