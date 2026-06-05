import 'package:physical_activity_log_app/models/user.dart';

class UserResponseDto {
  final int id;
  final String name;
  final String email;
  final String createdAt;

  const UserResponseDto({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      createdAt: json['createdAt'] as String,
    );
  }

  User toModel() => User(
        id: id,
        name: name,
        email: email,
        createdAt: DateTime.parse(createdAt),
      );
}
