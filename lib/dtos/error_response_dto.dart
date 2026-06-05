class ErrorResponseDto {
  final String message;

  const ErrorResponseDto({required this.message});

  factory ErrorResponseDto.fromJson(Map<String, dynamic> json) {
    return ErrorResponseDto(
      message: json['message'] as String? ?? 'Ocurrió un error inesperado',
    );
  }
}
