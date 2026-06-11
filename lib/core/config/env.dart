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

  /// Spotify OAuth client ID (from https://developer.spotify.com/dashboard).
  static String get spotifyClientId =>
      dotenv.env['SPOTIFY_CLIENT_ID']?.trim() ?? '';

  /// Spotify OAuth client secret.
  static String get spotifyClientSecret =>
      dotenv.env['SPOTIFY_CLIENT_SECRET']?.trim() ?? '';
}
