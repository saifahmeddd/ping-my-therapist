import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ping_my_therapist/screens/guided_breathing_screen.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';
import 'package:ping_my_therapist/widgets/stretchy_section_page.dart';

class BreathingExercisesScreen extends StatelessWidget {
  final bool showBackButton;

  const BreathingExercisesScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return StretchySectionPage(
      title: 'Breathing exercises',
      subtitle: 'Find a steady rhythm that feels right for you.',
      icon: Icons.air_rounded,
      leading:
          showBackButton
              ? const Align(
                alignment: Alignment.centerLeft,
                child: CustomBackButton(iconColor: Colors.white, iconSize: 24),
              )
              : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose your practice',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF292735),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Move at your own pace. You can pause or stop at any time.',
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 13,
              color: Color(0xFF6F6B7D),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(breathingExercises.length, (index) {
            final exercise = breathingExercises[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ExerciseCard(
                title: exercise.title,
                duration: exercise.shortDuration,
                focusArea: exercise.focusArea,
                rhythm: exercise.rhythmLabel,
                imageAsset: exercise.imageAsset,
                accentColor: exercise.color,
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => BreathingExerciseIntroScreen(
                              exercise: exercise,
                            ),
                      ),
                    ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String title;
  final String duration;
  final String focusArea;
  final String rhythm;
  final String imageAsset;
  final Color accentColor;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.title,
    required this.duration,
    required this.focusArea,
    required this.rhythm,
    required this.imageAsset,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey('breathing-card-$title'),
      button: true,
      label: '$title, $duration, $focusArea, $rhythm second rhythm',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDCD8F1), width: 1.5),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F35355F),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 325;
                final imageSize = compact ? 84.0 : 104.0;
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 48,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 18,
                                  height: 1.25,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF292735),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MetaPill(
                                icon: Icons.schedule_rounded,
                                label: duration,
                                color: accentColor,
                              ),
                              const SizedBox(height: 6),
                              _MetaPill(
                                icon: Icons.air_rounded,
                                label: rhythm,
                                color: accentColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            focusArea,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF6F6B7D),
                              fontFamily: 'General Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Start exercise',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontFamily: 'General Sans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: accentColor,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      width: imageSize,
                      height: imageSize,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SvgPicture.asset(imageAsset, fit: BoxFit.contain),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
