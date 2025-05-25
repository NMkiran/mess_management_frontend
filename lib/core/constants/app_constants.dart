class AppConstants {
  // App Info
  static const String appName = 'Mess Management';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';

  // Route Names
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String membersRoute = '/members';
  static const String expensesRoute = '/expenses';
  static const String paymentsRoute = '/payments';
  static const String attendanceRoute = '/attendance';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Error Messages
  static const String networkError = 'No internet connection';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String invalidCredentials = 'Invalid email or password';
  static const String sessionExpired =
      'Your session has expired. Please login again';
}
