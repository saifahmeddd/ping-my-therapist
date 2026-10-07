import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ping_my_therapist/services/spotify_service.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';
import 'package:ping_my_therapist/widgets/pullable_section_header.dart';
import 'package:ping_my_therapist/widgets/stretchy_section_page.dart';

class MusicRecommendationScreen extends StatefulWidget {
  const MusicRecommendationScreen({super.key});

  @override
  State<MusicRecommendationScreen> createState() =>
      _MusicRecommendationScreenState();
}

class _MusicRecommendationScreenState extends State<MusicRecommendationScreen> {
  static const _primaryColor = Color(0xFF535394);
  static const _accentColor = Color(0xFF7D7DDE);
  static const _surfaceColor = Color(0xFFE5E5F8);

  final _spotifyService = SpotifyService();

  bool _isLoading = true;
  String? _error;
  List<String> _moods = [];
  bool _noMoodRecorded = false;
  SpotifyResults? _spotifyResults;
  List<FallbackPlaylist> _fallbackPlaylists = [];
  bool _usingFallback = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _noMoodRecorded = false;
    });

    try {
      // ── 1. Fetch the latest mood check-in from Firestore ──────────────────
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snap =
            await FirebaseFirestore.instance
                .collection('mood_checkins')
                .where('userId', isEqualTo: user.uid)
                .get();

        if (snap.docs.isNotEmpty) {
          final sorted =
              snap.docs.toList()..sort((a, b) {
                final aTime = a.data()['timestamp'];
                final bTime = b.data()['timestamp'];
                if (aTime is Timestamp && bTime is Timestamp) {
                  return bTime.compareTo(aTime);
                }
                return 0;
              });
          final data = sorted.first.data();
          _moods = List<String>.from(data['moods'] as List? ?? []);
        } else {
          _noMoodRecorded = true;
        }
      }

      // ── 2. Get music recommendations ────────────────────────────────────
      if (!_noMoodRecorded) {
        if (_spotifyService.hasCredentials) {
          try {
            _spotifyResults = await _spotifyService.getRecommendations(_moods);
            _usingFallback = false;
          } catch (_) {
            // Spotify failed — show mood-based fallback playlists instead of crashing
            _fallbackPlaylists = _spotifyService.getFallbackForMoods(_moods);
            _usingFallback = true;
          }
        } else {
          _fallbackPlaylists = _spotifyService.getFallbackForMoods(_moods);
          _usingFallback = true;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openSpotify(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Spotify. Is it installed?'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: sectionPurple,
        body: SafeArea(
          child: Column(
            children: [
              const PullableSectionHeader(
                title: 'Music Therapy',
                subtitle: 'Find something that fits this moment.',
                leading: CustomBackButton(
                  iconColor: Colors.white,
                  iconSize: 24,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: ColoredBox(color: Colors.white, child: _buildBody()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoadingState();
    if (_error != null) return _buildErrorState();
    if (_noMoodRecorded) return _buildNoMoodState();
    return _buildContent();
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Finding your music…',
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _surfaceColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontFamily: 'quicksand',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'We couldn\'t load your music recommendations. Please check your connection and try again.',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── No mood recorded ─────────────────────────────────────────────────────

  Widget _buildNoMoodState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: _surfaceColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 48,
                color: _primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Check in first',
              style: TextStyle(
                fontFamily: 'quicksand',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Log how you\'re feeling today and we\'ll suggest music that matches your mood.',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => context.push(RouteNames.mood),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Open Mood Tracker',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main content ─────────────────────────────────────────────────────────

  Widget _buildContent() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildHeader(),
        if (_usingFallback) ...[
          _buildFallbackBanner(),
          _buildFallbackSection(),
        ] else if (_spotifyResults != null) ...[
          if (_spotifyResults!.tracks.isNotEmpty)
            _buildTracksSection(_spotifyResults!.tracks),
          if (_spotifyResults!.playlists.isNotEmpty)
            _buildPlaylistsSection(_spotifyResults!.playlists),
          if (_spotifyResults!.tracks.isEmpty &&
              _spotifyResults!.playlists.isEmpty)
            _buildEmptySpotifyResults(),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _usingFallback
                ? 'Curated playlists for your wellbeing'
                : 'Tuned to how you\'re feeling today',
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 13,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          if (_moods.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _moods.map((mood) => _MoodChip(label: mood)).toList(),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1C4E9), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: _primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Spotify is unavailable right now. Explore these playlists instead.',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 12,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended for you',
            style: TextStyle(
              fontFamily: 'quicksand',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ..._fallbackPlaylists.map(
            (p) => _FallbackPlaylistTile(
              playlist: p,
              onTap: () => _openSpotify(p.spotifyUrl),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTracksSection(List<SpotifyTrack> tracks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'Songs',
            style: TextStyle(
              fontFamily: 'quicksand',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            itemCount: tracks.length,
            itemBuilder:
                (context, i) => _TrackCard(
                  track: tracks[i],
                  onTap: () => _openSpotify(tracks[i].spotifyUrl),
                ),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildPlaylistsSection(List<SpotifyPlaylist> playlists) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Playlists',
            style: TextStyle(
              fontFamily: 'quicksand',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...playlists.map(
            (p) => _PlaylistTile(
              playlist: p,
              onTap: () => _openSpotify(p.spotifyUrl),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySpotifyResults() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(
            Icons.music_off_rounded,
            size: 48,
            color: Color(0xFFBBBBBB),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for your mood.',
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _MoodChip extends StatelessWidget {
  final String label;

  const _MoodChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBB3FF), width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'General Sans',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF535394),
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final SpotifyTrack track;
  final VoidCallback onTap;

  const _TrackCard({required this.track, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5F8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child:
                  track.albumArtUrl != null
                      ? Image.network(
                        track.albumArtUrl!,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => _AlbumArtPlaceholder(height: 110),
                      )
                      : _AlbumArtPlaceholder(height: 110),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                track.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Text(
                track.artistNames,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 11,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Row(
                children: [
                  const _SpotifyBadge(),
                  const SizedBox(width: 4),
                  Text(
                    'Open',
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 10,
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final SpotifyPlaylist playlist;
  final VoidCallback onTap;

  const _PlaylistTile({required this.playlist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E5F8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  playlist.imageUrl != null
                      ? Image.network(
                        playlist.imageUrl!,
                        height: 62,
                        width: 62,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) =>
                                _AlbumArtPlaceholder(height: 62, width: 62),
                      )
                      : _AlbumArtPlaceholder(height: 62, width: 62),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    playlist.ownerName,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 11,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                  if (playlist.trackCount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${playlist.trackCount} tracks',
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 11,
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Open',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackPlaylistTile extends StatelessWidget {
  final FallbackPlaylist playlist;
  final VoidCallback onTap;

  const _FallbackPlaylistTile({required this.playlist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E5F8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  playlist.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    playlist.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 11,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Open',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumArtPlaceholder extends StatelessWidget {
  final double height;
  final double? width;

  const _AlbumArtPlaceholder({required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      color: const Color(0xFFE5E5F8),
      child: const Icon(
        Icons.music_note_rounded,
        color: Color(0xFF7D7DDE),
        size: 28,
      ),
    );
  }
}

class _SpotifyBadge extends StatelessWidget {
  const _SpotifyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1DB954),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Spotify',
        style: TextStyle(
          fontFamily: 'General Sans',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
