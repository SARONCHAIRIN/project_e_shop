import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get appName =>
      dotenv.env['APP_NAME'] ?? 'My App';

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? '';

  static String get mapboxToken =>
      dotenv.env['MAPBOX_TOKEN'] ?? '';

  // static String get jwtSecret =>
  //     dotenv.env['JWT_SECRET'] ?? '';
}