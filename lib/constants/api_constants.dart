abstract final class ApiConstants {
  static const String baseUrl =
      'https://physical-activity-log-api.onrender.com/api/v1';

  static const String authRegister = '$baseUrl/auth/register';
  static const String authLogin = '$baseUrl/auth/login';
  static const String authMe = '$baseUrl/auth/me';

  static const String categories = '$baseUrl/categories';

  static String category(int id) => '$categories/$id';
  static const String activities = '$baseUrl/activities';
  static const String trainingSessions = '$baseUrl/training-sessions';

  static String trainingSession(int id) => '$trainingSessions/$id';
}
