import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed accessors for values loaded from `.env` via [dotenv].
abstract final class Env {
  /// Base URL for REST API calls. Falls back if unset or empty.
  static String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      return 'https://api.example.com';
    }
    return value;
  }
}
