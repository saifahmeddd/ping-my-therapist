import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

class SpotifyTrack {
  final String id;
  final String name;
  final String artistNames;
  final String? albumArtUrl;
  final String spotifyUrl;

  const SpotifyTrack({
    required this.id,
    required this.name,
    required this.artistNames,
    this.albumArtUrl,
    required this.spotifyUrl,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    final artists = (json['artists'] as List<dynamic>? ?? [])
        .map((a) => (a as Map<String, dynamic>)['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .join(', ');
    final images = (json['album'] as Map<String, dynamic>?)?['images']
            as List<dynamic>? ??
        [];
    final artUrl = images.isNotEmpty
        ? (images.first as Map<String, dynamic>)['url'] as String?
        : null;
    return SpotifyTrack(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      artistNames: artists.isEmpty ? 'Unknown Artist' : artists,
      albumArtUrl: artUrl,
      spotifyUrl:
          ((json['external_urls'] as Map<String, dynamic>?)?['spotify']
                  as String?) ??
              '',
    );
  }
}

class SpotifyPlaylist {
  final String id;
  final String name;
  final String ownerName;
  final String? imageUrl;
  final String spotifyUrl;
  final int? trackCount;

  const SpotifyPlaylist({
    required this.id,
    required this.name,
    required this.ownerName,
    this.imageUrl,
    required this.spotifyUrl,
    this.trackCount,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty
        ? (images.first as Map<String, dynamic>)['url'] as String?
        : null;
    return SpotifyPlaylist(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      ownerName:
          ((json['owner'] as Map<String, dynamic>?)?['display_name']
                  as String?) ??
              'Spotify',
      imageUrl: imageUrl,
      spotifyUrl:
          ((json['external_urls'] as Map<String, dynamic>?)?['spotify']
                  as String?) ??
              '',
      trackCount:
          ((json['tracks'] as Map<String, dynamic>?)?['total'] as num?)
              ?.toInt(),
    );
  }
}

class SpotifyResults {
  final List<SpotifyTrack> tracks;
  final List<SpotifyPlaylist> playlists;
  final String moodLabel;

  const SpotifyResults({
    required this.tracks,
    required this.playlists,
    required this.moodLabel,
  });
}

/// A curated playlist shown when Spotify credentials are not configured.
class FallbackPlaylist {
  final String name;
  final String description;
  final String spotifyUrl;
  final String emoji;

  const FallbackPlaylist({
    required this.name,
    required this.description,
    required this.spotifyUrl,
    required this.emoji,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class SpotifyService {
  static const _tokenUrl = 'https://accounts.spotify.com/api/token';
  static const _searchUrl = 'https://api.spotify.com/v1/search';

  String? _accessToken;
  DateTime? _tokenExpiry;

  /// Maps the app's mood labels (from MoodCheckinScreen) to Spotify search queries.
  static const Map<String, String> _moodToQuery = {
    'Light & Clear': 'peaceful calm ambient focus relaxation',
    'Chaotic & Scattered': 'stress relief lo-fi calming focus',
    'Grounded & Growing': 'uplifting motivational acoustic hopeful',
    'Heavy & Drowning': 'healing comforting soft piano gentle',
    'Cloudy & Low': 'mood lifting feel good gentle upbeat',
    'Wired & On edge': 'meditation anxiety calm breathing sleep',
  };

  /// Curated fallback playlists per mood (well-known public Spotify playlists).
  static const Map<String, List<FallbackPlaylist>> _fallbackPlaylists = {
    'Light & Clear': [
      FallbackPlaylist(
        name: 'Peaceful Piano',
        description: 'Sit back and relax with beautiful piano instrumentals',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO',
        emoji: '🎹',
      ),
      FallbackPlaylist(
        name: 'Calm Vibes',
        description: 'Keep calm and unwind with these easy-going sounds',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWTnnpDDHl7PF',
        emoji: '🌿',
      ),
    ],
    'Chaotic & Scattered': [
      FallbackPlaylist(
        name: 'Deep Focus',
        description: 'Keep calm and focused with minimal distractions',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ',
        emoji: '🧠',
      ),
      FallbackPlaylist(
        name: 'Brain Food',
        description: 'Music to sharpen your thinking',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWXLeA8Omikj7',
        emoji: '🎧',
      ),
    ],
    'Grounded & Growing': [
      FallbackPlaylist(
        name: 'Mood Booster',
        description: 'Feeling low? Lift your mood with this playlist!',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX3rxVfibe1L0',
        emoji: '✨',
      ),
      FallbackPlaylist(
        name: 'Have a Great Day!',
        description: 'Start your day with the right energy',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX1s9knjP51Oa',
        emoji: '🌅',
      ),
    ],
    'Heavy & Drowning': [
      FallbackPlaylist(
        name: 'Feeling Blue',
        description: 'Sometimes music is the comfort you need',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX7qK8ma5wgG1',
        emoji: '💙',
      ),
      FallbackPlaylist(
        name: 'Acoustic Concentration',
        description: 'Soft acoustic songs to help you recentre',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWXe9gFZP0gtP',
        emoji: '🎸',
      ),
    ],
    'Cloudy & Low': [
      FallbackPlaylist(
        name: 'Feel Good Piano',
        description: 'Beautiful piano pieces to lift the spirit',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX889U0CL85jj',
        emoji: '🌸',
      ),
      FallbackPlaylist(
        name: 'Mood Booster',
        description: 'Feeling low? Lift your mood with this playlist!',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX3rxVfibe1L0',
        emoji: '🌻',
      ),
    ],
    'Wired & On edge': [
      FallbackPlaylist(
        name: 'Sleep',
        description: 'Gentle music to help you unwind and drift off',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DWZd79rJ6a7lp',
        emoji: '🌙',
      ),
      FallbackPlaylist(
        name: 'Peaceful Piano',
        description: 'Calming piano to ease a restless mind',
        spotifyUrl:
            'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO',
        emoji: '🧘',
      ),
    ],
  };

  static const List<FallbackPlaylist> _defaultFallback = [
    FallbackPlaylist(
      name: 'Peaceful Piano',
      description: 'Sit back and relax with beautiful piano instrumentals',
      spotifyUrl: 'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO',
      emoji: '🎹',
    ),
    FallbackPlaylist(
      name: 'Calm Vibes',
      description: 'Keep calm and unwind with these easy-going sounds',
      spotifyUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWTnnpDDHl7PF',
      emoji: '🌿',
    ),
    FallbackPlaylist(
      name: 'Deep Focus',
      description: 'Keep calm and focused',
      spotifyUrl: 'https://open.spotify.com/playlist/37i9dQZF1DWZeKCadgRdKQ',
      emoji: '🧠',
    ),
  ];

  /// Returns true when valid Spotify credentials are present in .env.
  bool get hasCredentials {
    final id = dotenv.env['SPOTIFY_CLIENT_ID']?.trim() ?? '';
    final secret = dotenv.env['SPOTIFY_CLIENT_SECRET']?.trim() ?? '';
    return id.isNotEmpty &&
        id != 'your_spotify_client_id_here' &&
        secret.isNotEmpty &&
        secret != 'your_spotify_client_secret_here';
  }

  /// Returns curated fallback playlists for the given mood labels.
  List<FallbackPlaylist> getFallbackForMoods(List<String> moods) {
    for (final mood in moods) {
      final playlists = _fallbackPlaylists[mood];
      if (playlists != null) return playlists;
    }
    return _defaultFallback;
  }

  /// Returns a human-readable summary of the mood list.
  String moodSummary(List<String> moods) {
    if (moods.isEmpty) return 'your mood';
    if (moods.length == 1) return moods.first;
    return '${moods.first} & more';
  }

  String _queryForMoods(List<String> moods) {
    for (final mood in moods) {
      final q = _moodToQuery[mood];
      if (q != null) return q;
    }
    return 'calming peaceful music';
  }

  Future<String> _getAccessToken() async {
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken!;
    }

    final clientId = dotenv.env['SPOTIFY_CLIENT_ID']!.trim();
    final clientSecret = dotenv.env['SPOTIFY_CLIENT_SECRET']!.trim();
    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'grant_type': 'client_credentials'},
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Spotify authentication failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _accessToken = data['access_token'] as String;
    final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 3600;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn - 60));
    return _accessToken!;
  }

  /// Fetches tracks and playlists from Spotify based on the user's moods.
  Future<SpotifyResults> getRecommendations(List<String> moods) async {
    final query = _queryForMoods(moods);
    final token = await _getAccessToken();

    final uri = Uri.parse(_searchUrl).replace(queryParameters: {
      'q': query,
      'type': 'track,playlist',
      'limit': '6',
      'market': 'US',
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Spotify search failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tracksRaw = data['tracks']?['items'] as List<dynamic>? ?? [];
    final playlistsRaw = data['playlists']?['items'] as List<dynamic>? ?? [];

    final tracks = tracksRaw
        .whereType<Map<String, dynamic>>()
        .map(SpotifyTrack.fromJson)
        .where((t) => t.id.isNotEmpty && t.spotifyUrl.isNotEmpty)
        .take(5)
        .toList();

    final playlists = playlistsRaw
        .whereType<Map<String, dynamic>>()
        .map(SpotifyPlaylist.fromJson)
        .where((p) => p.id.isNotEmpty && p.spotifyUrl.isNotEmpty)
        .take(4)
        .toList();

    return SpotifyResults(
      tracks: tracks,
      playlists: playlists,
      moodLabel: moodSummary(moods),
    );
  }
}
