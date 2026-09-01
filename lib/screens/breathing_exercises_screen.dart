import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ping_my_therapist/screens/guided_breathing_screen.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

class BreathingExercisesScreen extends StatelessWidget {
  final bool showBackButton;

  const BreathingExercisesScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF535394),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 40,
                left: 0,
                right: 24,
                bottom: 32,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showBackButton) ...[
                    const CustomBackButton(
                      iconColor: Colors.white,
                      iconSize: 24,
                    ),
                    const SizedBox(width: 2),
                  ] else
                    const SizedBox(width: 24),
                  const Expanded(
                    child: Text(
                      'Breathing Exercises',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    children: List.generate(breathingExercises.length, (index) {
                      final exercise = breathingExercises[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom:
                              index == breathingExercises.length - 1 ? 0 : 24,
                        ),
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
                  ),
                ),
              ),
            ),
          ],
        ),
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
                              Text(
                                'Start exercise',
                                style: TextStyle(
                                  color: accentColor,
                                  fontFamily: 'General Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
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
          Text(
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
        ],
      ),
    );
  }
}
