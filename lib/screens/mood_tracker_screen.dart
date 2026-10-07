import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/theme/app_colors.dart';
import 'package:ping_my_therapist/widgets/stretchy_section_page.dart';

class MoodCheckinEntry {
  final String label;
  final int wellbeingScore;
  final DateTime? timestamp;
  final List<String> emotions;

  const MoodCheckinEntry({
    required this.label,
    required this.wellbeingScore,
    required this.timestamp,
    required this.emotions,
  });

  factory MoodCheckinEntry.fromMap(Map<String, dynamic> data) {
    final moods = List<String>.from(data['moods'] as List? ?? const []);
    final displayMood = (data['displayMood'] as String?)?.trim();
    final storedScale = data['moodScale'];
    final score =
        storedScale is num
            ? (6 - storedScale.round()).clamp(1, 5)
            : _scoreForMood(moods.isEmpty ? '' : moods.first);
    final rawTimestamp = data['timestamp'];

    return MoodCheckinEntry(
      label:
          displayMood?.isNotEmpty == true
              ? displayMood!
              : (moods.isEmpty ? 'Mood check-in' : moods.join(' · ')),
      wellbeingScore: score,
      timestamp:
          rawTimestamp is Timestamp
              ? rawTimestamp.toDate()
              : rawTimestamp is DateTime
              ? rawTimestamp
              : null,
      emotions: List<String>.from(data['emotions'] as List? ?? const []),
    );
  }

  static int _scoreForMood(String mood) {
    return switch (mood) {
      'Grounded & Growing' => 5,
      'Light & Clear' => 4,
      'Chaotic & Scattered' || 'Wired & On edge' => 3,
      'Cloudy & Low' => 2,
      'Heavy & Drowning' => 1,
      _ => 3,
    };
  }
}

class MoodTrackerScreen extends StatelessWidget {
  final Stream<List<MoodCheckinEntry>>? checkinsStream;

  const MoodTrackerScreen({super.key, this.checkinsStream});

  Stream<List<MoodCheckinEntry>> _watchCheckins() {
    if (checkinsStream case final stream?) return stream;
    User? user;
    try {
      user = FirebaseAuth.instance.currentUser;
    } catch (_) {
      return Stream.value(const []);
    }
    if (user == null) return Stream.value(const []);

    return FirebaseFirestore.instance
        .collection('mood_checkins')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final entries =
              snapshot.docs
                  .map((document) => MoodCheckinEntry.fromMap(document.data()))
                  .toList();
          entries.sort((a, b) {
            final aTime = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });
          return entries.take(30).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MoodCheckinEntry>>(
      stream: _watchCheckins(),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <MoodCheckinEntry>[];
        return StretchySectionPage(
          title: 'Mood Tracker',
          subtitle: 'Notice patterns without judging them.',
          icon: Icons.insights_rounded,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CheckInCard(
                onQuickCheckIn: () => context.push(RouteNames.moodCheckin),
                onNameFeelings: () => context.push(RouteNames.nameWhatYouFeel),
              ),
              const SizedBox(height: 16),
              if (snapshot.hasError)
                const _MessageCard(
                  icon: Icons.cloud_off_rounded,
                  title: 'Check-ins are temporarily unavailable',
                  message:
                      'Your data is safe. Check your connection and try again shortly.',
                )
              else if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData)
                const _LoadingCard()
              else ...[
                _WeekOverview(entries: entries),
                const SizedBox(height: 16),
                _LatestReflection(
                  entry: entries.isEmpty ? null : entries.first,
                ),
                const SizedBox(height: 16),
                _RecentCheckIns(entries: entries.take(5).toList()),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final VoidCallback onQuickCheckIn;
  final VoidCallback onNameFeelings;

  const _CheckInCard({
    required this.onQuickCheckIn,
    required this.onNameFeelings,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling right now?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Quicksand',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'A small check-in can make the rest of the day easier to understand.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'General Sans',
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.add_reaction_outlined,
                  label: 'Quick check-in',
                  onTap: onQuickCheckIn,
                  filled: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Name feelings',
                  onTap: onNameFeelings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : AppColors.primary;
    return Material(
      color: filled ? AppColors.primary : AppColors.primarySurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontFamily: 'General Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekOverview extends StatelessWidget {
  final List<MoodCheckinEntry> entries;

  const _WeekOverview({required this.entries});

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final days = List.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );
    final dailyEntries =
        days.map((day) {
          for (final entry in entries) {
            if (entry.timestamp != null &&
                DateUtils.isSameDay(entry.timestamp, day)) {
              return entry;
            }
          }
          return null;
        }).toList();
    final weekCount =
        entries.where((entry) {
          final timestamp = entry.timestamp;
          return timestamp != null &&
              !DateUtils.dateOnly(timestamp).isBefore(days.first);
        }).length;
    final streak = _currentStreak(entries, today);

    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _SectionTitle('This week')),
              _StatChip(
                icon: Icons.local_fire_department_rounded,
                label: '$streak day streak',
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            weekCount == 0
                ? 'Your seven-day view will grow with each check-in.'
                : '$weekCount check-in${weekCount == 1 ? '' : 's'} in the last seven days',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'General Sans',
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 105,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(days.length, (index) {
                return Expanded(
                  child: _DayBar(
                    day: days[index],
                    entry: dailyEntries[index],
                    isToday: index == days.length - 1,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('low', style: _legendTextStyle),
              SizedBox(width: 6),
              _GradientLegend(),
              SizedBox(width: 6),
              Text('bright', style: _legendTextStyle),
            ],
          ),
        ],
      ),
    );
  }

  static const _legendTextStyle = TextStyle(
    color: AppColors.textMuted,
    fontFamily: 'General Sans',
    fontSize: 9,
  );

  int _currentStreak(List<MoodCheckinEntry> entries, DateTime today) {
    final checkedDays =
        entries
            .where((entry) => entry.timestamp != null)
            .map((entry) => DateUtils.dateOnly(entry.timestamp!))
            .toSet();
    var cursor = today;
    if (!checkedDays.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (checkedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

class _DayBar extends StatelessWidget {
  final DateTime day;
  final MoodCheckinEntry? entry;
  final bool isToday;

  const _DayBar({
    required this.day,
    required this.entry,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final score = entry?.wellbeingScore ?? 0;
    final color = _moodColor(score);
    return Semantics(
      label:
          '${DateFormat('EEEE').format(day)}, ${entry?.label ?? 'no check-in'}',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: 22,
            height: entry == null ? 9 : 24 + (score * 9),
            decoration: BoxDecoration(
              color: entry == null ? AppColors.borderLight : color,
              borderRadius: BorderRadius.circular(12),
              boxShadow:
                  entry == null
                      ? null
                      : [
                        BoxShadow(
                          color: color.withValues(alpha: 0.24),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('E').format(day).substring(0, 1),
            style: TextStyle(
              color: isToday ? AppColors.primary : AppColors.textMuted,
              fontFamily: 'General Sans',
              fontSize: 10,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestReflection extends StatelessWidget {
  final MoodCheckinEntry? entry;

  const _LatestReflection({required this.entry});

  @override
  Widget build(BuildContext context) {
    final current = entry;
    if (current == null) {
      return const _MessageCard(
        icon: Icons.auto_awesome_rounded,
        title: 'Your first pattern starts here',
        message:
            'Check in today, then come back to notice what changes over time.',
      );
    }

    return _SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _moodColor(current.wellbeingScore).withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _moodIcon(current.wellbeingScore),
              color: _moodColor(current.wellbeingScore),
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LATEST REFLECTION',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'General Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  current.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Quicksand',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (current.timestamp != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('MMM d · h:mm a').format(current.timestamp!),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontFamily: 'General Sans',
                      fontSize: 10,
                    ),
                  ),
                ],
                if (current.emotions.isNotEmpty) ...[
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        current.emotions
                            .take(3)
                            .map((emotion) => _EmotionChip(emotion))
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCheckIns extends StatelessWidget {
  final List<MoodCheckinEntry> entries;

  const _RecentCheckIns({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return _SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: _SectionTitle('Recent check-ins'),
          ),
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: _moodColor(
                          entry.wellbeingScore,
                        ).withValues(alpha: 0.12),
                        child: Icon(
                          _moodIcon(entry.wellbeingScore),
                          color: _moodColor(entry.wellbeingScore),
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          entry.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontFamily: 'General Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.timestamp == null
                            ? 'Recently'
                            : DateFormat('MMM d').format(entry.timestamp!),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontFamily: 'General Sans',
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != entries.length - 1)
                  const Divider(height: 1, indent: 65, endIndent: 18),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D35355F),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const _SurfaceCard(
      child: SizedBox(
        height: 130,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: AppColors.primarySurface,
            child: Icon(icon, color: AppColors.primary, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'General Sans',
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontFamily: 'Quicksand',
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontFamily: 'General Sans',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionChip extends StatelessWidget {
  final String label;

  const _EmotionChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontFamily: 'General Sans',
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GradientLegend extends StatelessWidget {
  const _GradientLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 5,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B7AAE), Color(0xFF69B9A2)],
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

Color _moodColor(int score) {
  return switch (score) {
    1 => const Color(0xFF8B7AAE),
    2 => const Color(0xFF827FC1),
    3 => const Color(0xFF7D7DDE),
    4 => const Color(0xFF58A9BB),
    5 => const Color(0xFF69B9A2),
    _ => AppColors.textMuted,
  };
}

IconData _moodIcon(int score) {
  return switch (score) {
    1 => Icons.sentiment_very_dissatisfied_rounded,
    2 => Icons.sentiment_dissatisfied_rounded,
    3 => Icons.sentiment_neutral_rounded,
    4 => Icons.sentiment_satisfied_rounded,
    5 => Icons.sentiment_very_satisfied_rounded,
    _ => Icons.sentiment_neutral_rounded,
  };
}
