class AppConstants {
  static const String appName = 'AutoSalon';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  // Pagination
  static const int itemsPerPage = 20;

  // Date formats
  static const String dateFormat = 'dd.MM.yyyy';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
}

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String cars = '/cars';
  static const String carDetail = '/cars/:id';
  static const String clients = '/clients';
  static const String clientDetail = '/clients/:id';
  static const String deals = '/deals';
  static const String createDeal = '/deals/create';
  static const String employees = '/employees';
  static const String profile = '/profile';
}