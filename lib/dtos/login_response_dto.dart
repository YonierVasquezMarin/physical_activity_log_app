class LoginResponseDto {
  final String token;
  final String tokenType;
  final int expiresIn;

  const LoginResponseDto({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      token: json['token'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: json['expiresIn'] as int,
    );
  }
}
