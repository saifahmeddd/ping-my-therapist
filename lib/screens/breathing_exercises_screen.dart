import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ping_my_therapist/screens/box_breathing_walkthrough.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

class BreathingExercisesScreen extends StatelessWidget {
  const BreathingExercisesScreen({super.key});

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
                  CustomBackButton(iconColor: Colors.white, iconSize: 24),
                  const SizedBox(width: 2),
                  const Text(
                    'Breathing Exercises',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.5,
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
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const BoxBreathingWalkthroughScreen(),
                          ),
                        ),
                        child: const _ExerciseCard(
                          title: 'Box Breathing',
                          duration: '4 minutes',
                          focusArea: 'Stress & Anxiety',
                          imageAsset: 'assets/images/positive-thinking.svg',
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _ExerciseCard(
                        title: '4-7-8 Breathing',
                        duration: '3 minutes',
                        focusArea: 'Sleep & Panic Relief',
                        imageAsset: 'assets/images/personal-growth.svg',
                      ),
                      const SizedBox(height: 24),
                      const _ExerciseCard(
                        title: 'Tactical Breathing',
                        duration: '5 minutes',
                        focusArea: 'High-Stress Situations',
                        imageAsset: 'assets/images/breathing.svg',
                      ),
                      const SizedBox(height: 24),
                      const _ExerciseCard(
                        title: 'Double Inhale and Sigh',
                        duration: '2 minutes',
                        focusArea: 'Quick Reset',
                        imageAsset: 'assets/images/meditation.svg',
                      ),
                      const SizedBox(height: 24),
                      const _ExerciseCard(
                        title: 'Diaphragmatic Breathing',
                        duration: '5 minutes',
                        focusArea: 'Relaxation',
                        imageAsset: 'assets/images/positive-thinking.svg',
                      ),
                      const SizedBox(height: 24),
                      const _ExerciseCard(
                        title: '3-3-3 Breathing',
                        duration: '3 minutes',
                        focusArea: 'Grounding',
                        imageAsset: 'assets/images/happy-earth.svg',
                      ),
                      const SizedBox(height: 24),
                      const _ExerciseCard(
                        title: 'Coherent Breathing',
                        duration: '6 minutes',
                        focusArea: 'Balance & Calm',
                        imageAsset: 'assets/images/self-love.svg',
                      ),
                    ],
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
  final String imageAsset;

  const _ExerciseCard({
    required this.title,
    required this.duration,
    required this.focusArea,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1C4E9), width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Duration:', value: duration),
                const SizedBox(height: 4),
                _InfoRow(label: 'Focus Area:', value: focusArea),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 110,
            width: 110,
            child: SvgPicture.asset(imageAsset, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'General Sans',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'General Sans',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
