import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

enum BreathAction { inhale, holdFull, exhale, holdEmpty, topUp }

class BreathPhase {
  final BreathAction action;
  final String label;
  final String instruction;
  final int seconds;
  final double startScale;
  final double endScale;

  const BreathPhase({
    required this.action,
    required this.label,
    required this.instruction,
    required this.seconds,
    required this.startScale,
    required this.endScale,
  });

  bool get isHold =>
      action == BreathAction.holdFull || action == BreathAction.holdEmpty;
}

class BreathingExercise {
  final String title;
  final String shortDuration;
  final String focusArea;
  final String description;
  final String preparation;
  final String tip;
  final String imageAsset;
  final Color color;
  final int cycles;
  final List<BreathPhase> phases;

  const BreathingExercise({
    required this.title,
    required this.shortDuration,
    required this.focusArea,
    required this.description,
    required this.preparation,
    required this.tip,
    required this.imageAsset,
    required this.color,
    required this.cycles,
    required this.phases,
  });

  int get cycleSeconds =>
      phases.fold(0, (total, phase) => total + phase.seconds);

  int get totalSeconds => cycleSeconds * cycles;

  String get rhythmLabel => phases.map((phase) => phase.seconds).join(' · ');

  bool get includesBreathHold => phases.any((phase) => phase.isHold);
}

const inhale4 = BreathPhase(
  action: BreathAction.inhale,
  label: 'Breathe in',
  instruction: 'Inhale gently through your nose',
  seconds: 4,
  startScale: 0.62,
  endScale: 1,
);

const holdFull4 = BreathPhase(
  action: BreathAction.holdFull,
  label: 'Hold',
  instruction: 'Pause softly — do not strain',
  seconds: 4,
  startScale: 1,
  endScale: 1,
);

const exhale4 = BreathPhase(
  action: BreathAction.exhale,
  label: 'Breathe out',
  instruction: 'Exhale slowly through your mouth',
  seconds: 4,
  startScale: 1,
  endScale: 0.62,
);

const holdEmpty4 = BreathPhase(
  action: BreathAction.holdEmpty,
  label: 'Hold empty',
  instruction: 'Rest gently before the next breath',
  seconds: 4,
  startScale: 0.62,
  endScale: 0.62,
);

const breathingExercises = <BreathingExercise>[
  BreathingExercise(
    title: 'Box Breathing',
    shortDuration: '4 minutes',
    focusArea: 'Stress & Anxiety',
    description:
        'An even four-part rhythm that gives your attention something steady to follow.',
    preparation:
        'Sit upright with both feet supported. Let your shoulders soften before you begin.',
    tip: 'Imagine tracing one side of a square during each phase.',
    imageAsset: 'assets/images/positive-thinking.svg',
    color: Color(0xFF7D7DDE),
    cycles: 15,
    phases: [inhale4, holdFull4, exhale4, holdEmpty4],
  ),
  BreathingExercise(
    title: '4-7-8 Breathing',
    shortDuration: '4 cycles',
    focusArea: 'Sleep & Panic Relief',
    description:
        'A slow pattern with a longer exhale, designed to help your body shift toward rest.',
    preparation:
        'Sit comfortably or lie down. Rest the tip of your tongue behind your upper front teeth, then breathe out fully before the first cycle.',
    tip:
        'If the count feels too long, stop and return to your natural breathing.',
    imageAsset: 'assets/images/personal-growth.svg',
    color: Color(0xFF6868B9),
    cycles: 4,
    phases: [
      BreathPhase(
        action: BreathAction.inhale,
        label: 'Breathe in',
        instruction: 'Inhale quietly through your nose',
        seconds: 4,
        startScale: 0.62,
        endScale: 1,
      ),
      BreathPhase(
        action: BreathAction.holdFull,
        label: 'Hold',
        instruction: 'Hold gently without tightening',
        seconds: 7,
        startScale: 1,
        endScale: 1,
      ),
      BreathPhase(
        action: BreathAction.exhale,
        label: 'Breathe out',
        instruction: 'Exhale completely and slowly',
        seconds: 8,
        startScale: 1,
        endScale: 0.62,
      ),
    ],
  ),
  BreathingExercise(
    title: 'Tactical Breathing',
    shortDuration: '5 minutes',
    focusArea: 'High-Stress Situations',
    description:
        'A simple inhale, pause, and exhale cadence for regaining focus under pressure.',
    preparation:
        'Plant both feet, relax your jaw, and let the breath move into your belly rather than your chest.',
    tip: 'Let the six-second exhale stay smooth rather than forcing out air.',
    imageAsset: 'assets/images/breathing.svg',
    color: Color(0xFF535394),
    cycles: 30,
    phases: [
      BreathPhase(
        action: BreathAction.inhale,
        label: 'Breathe in',
        instruction: 'Inhale smoothly through your nose',
        seconds: 4,
        startScale: 0.62,
        endScale: 1,
      ),
      BreathPhase(
        action: BreathAction.exhale,
        label: 'Breathe out',
        instruction: 'Exhale slowly through your mouth',
        seconds: 6,
        startScale: 1,
        endScale: 0.62,
      ),
    ],
  ),
  BreathingExercise(
    title: 'Double Inhale and Sigh',
    shortDuration: '2 minutes',
    focusArea: 'Quick Reset',
    description:
        'Two nasal inhales followed by one long sighing exhale — a quick pattern for releasing tension.',
    preparation:
        'Keep the first inhale comfortable. The second inhale is only a small top-up, not a forceful breath.',
    tip: 'Let the long exhale leave through your mouth like a quiet sigh.',
    imageAsset: 'assets/images/meditation.svg',
    color: Color(0xFF8C88F8),
    cycles: 15,
    phases: [
      BreathPhase(
        action: BreathAction.inhale,
        label: 'Breathe in',
        instruction: 'Take a comfortable breath through your nose',
        seconds: 2,
        startScale: 0.62,
        endScale: 0.9,
      ),
      BreathPhase(
        action: BreathAction.topUp,
        label: 'Small top-up',
        instruction: 'Sip in a little more air through your nose',
        seconds: 1,
        startScale: 0.9,
        endScale: 1,
      ),
      BreathPhase(
        action: BreathAction.exhale,
        label: 'Long sigh out',
        instruction: 'Release slowly through your mouth',
        seconds: 5,
        startScale: 1,
        endScale: 0.62,
      ),
    ],
  ),
  BreathingExercise(
    title: 'Diaphragmatic Breathing',
    shortDuration: '5 minutes',
    focusArea: 'Relaxation',
    description:
        'Slow belly breathing that encourages a gentle rise on the inhale and a longer release.',
    preparation:
        'Place one hand on your chest and one on your belly. Aim for the lower hand to move more.',
    tip: 'Keep the upper chest quiet and let the belly soften outward.',
    imageAsset: 'assets/images/positive-thinking.svg',
    color: Color(0xFF6868B9),
    cycles: 50,
    phases: [
      BreathPhase(
        action: BreathAction.inhale,
        label: 'Belly rises',
        instruction: 'Inhale slowly through your nose',
        seconds: 2,
        startScale: 0.62,
        endScale: 1,
      ),
      BreathPhase(
        action: BreathAction.exhale,
        label: 'Belly softens',
        instruction: 'Exhale gently through pursed lips',
        seconds: 4,
        startScale: 1,
        endScale: 0.62,
      ),
    ],
  ),
  BreathingExercise(
    title: '3-3-3 Breathing',
    shortDuration: '3 minutes',
    focusArea: 'Grounding',
    description:
        'A short, memorable three-count rhythm for bringing attention back to the present.',
    preparation:
        'Find a comfortable posture and choose one point in front of you to rest your gaze.',
    tip:
        'Keep each count even and easy rather than trying to take a very deep breath.',
    imageAsset: 'assets/images/happy-earth.svg',
    color: Color(0xFF7777C7),
    cycles: 20,
    phases: [
      BreathPhase(
        action: BreathAction.inhale,
        label: 'Breathe in',
        instruction: 'Inhale gently through your nose',
        seconds: 3,
        startScale: 0.62,
        endScale: 1,
      ),
      BreathPhase(
        action: BreathAction.holdFull,
        label: 'Hold',
        instruction: 'Pause softly',
        seconds: 3,
        startScale: 1,
        endScale: 1,
      ),
      BreathPhase(
        action: BreathAction.exhale,
        label: 'Breathe out',
        instruction: 'Exhale slowly through your mouth',
        seconds: 3,
        startScale: 1,
        endScale: 0.62,
      ),
    ],
  ),
  BreathingExercise(
    title: 'Coherent Breathing',
    shortDuration: '6 minutes',
    focusArea: 'Balance & Calm',
    description:
        'An equal, unbroken rhythm of roughly six breaths per minute for steady, gentle pacing.',
    preparation:
        'Sit comfortably and allow each breath to flow into the next without holding at the top or bottom.',
    tip: 'Think of the breath as a smooth wave arriving and receding.',
    imageAsset: 'assets/images/self-love.svg',
    color: Color(0xFF535394),
    cycles: 36,
    phases: [
      BreathPhase(
        action: BreathAction.inhale,
        label: 'Breathe in',
        instruction: 'Inhale smoothly through your nose',
        seconds: 5,
        startScale: 0.62,
        endScale: 1,
      ),
      BreathPhase(
        action: BreathAction.exhale,
        label: 'Breathe out',
        instruction: 'Exhale smoothly and completely',
        seconds: 5,
        startScale: 1,
        endScale: 0.62,
      ),
    ],
  ),
];

class BreathingExerciseIntroScreen extends StatelessWidget {
  final BreathingExercise exercise;

  const BreathingExerciseIntroScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: exercise.color,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 20, 22, 22),
              child: Row(
                children: [
                  const CustomBackButton(iconColor: Colors.white, iconSize: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      exercise.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Quicksand',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(38),
                    topRight: Radius.circular(38),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 205,
                          child: SvgPicture.asset(
                            exercise.imageAsset,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _InfoPill(
                            icon: Icons.schedule_rounded,
                            label: exercise.shortDuration,
                            color: exercise.color,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: _InfoPill(
                              icon: Icons.favorite_border_rounded,
                              label: exercise.focusArea,
                              color: exercise.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _InfoPill(
                        icon: Icons.air_rounded,
                        label: '${exercise.rhythmLabel} second rhythm',
                        color: exercise.color,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'How it works',
                        style: TextStyle(
                          color: exercise.color,
                          fontFamily: 'General Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        exercise.description,
                        style: const TextStyle(
                          color: Color(0xFF292735),
                          fontFamily: 'Quicksand',
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            exercise.phases
                                .map(
                                  (phase) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F4FF),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFD1C4E9),
                                      ),
                                    ),
                                    child: Text(
                                      '${phase.label} · ${phase.seconds}s',
                                      style: const TextStyle(
                                        fontFamily: 'General Sans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      const SizedBox(height: 24),
                      _GuidanceCard(
                        icon: Icons.self_improvement_rounded,
                        title: 'Get comfortable',
                        text: exercise.preparation,
                        color: exercise.color,
                      ),
                      const SizedBox(height: 12),
                      _GuidanceCard(
                        icon: Icons.lightbulb_outline_rounded,
                        title: 'Helpful cue',
                        text: exercise.tip,
                        color: exercise.color,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 17,
                            color: Color(0xFF77738A),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              exercise.includesBreathHold
                                  ? 'Keep every breath gentle. If you have a heart or lung condition, check with your healthcare professional before trying breath holds. Stop if you feel dizzy or uncomfortable.'
                                  : 'Keep every breath gentle. Pause or stop if you feel dizzy, light-headed, or uncomfortable.',
                              style: const TextStyle(
                                color: Color(0xFF77738A),
                                fontFamily: 'General Sans',
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => GuidedBreathingScreen(
                                        exercise: exercise,
                                      ),
                                ),
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: exercise.color,
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'Start guided breathing',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'General Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
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

class GuidedBreathingScreen extends StatefulWidget {
  final BreathingExercise exercise;

  const GuidedBreathingScreen({super.key, required this.exercise});

  @override
  State<GuidedBreathingScreen> createState() => _GuidedBreathingScreenState();
}

class _GuidedBreathingScreenState extends State<GuidedBreathingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _phaseController;
  Timer? _countdownTimer;

  int _phaseIndex = 0;
  int _completedCycles = 0;
  int _elapsedBeforePhase = 0;
  int _countdown = 3;
  bool _started = false;
  bool _paused = false;
  bool _completed = false;
  bool _advancing = false;
  bool _allowExit = false;

  BreathPhase get _phase => widget.exercise.phases[_phaseIndex];

  @override
  void initState() {
    super.initState();
    _phaseController = AnimationController(vsync: this)
      ..addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _advancing || _completed) {
      return;
    }
    _advancing = true;
    scheduleMicrotask(_advancePhase);
  }

  void _beginCountdown() {
    if (_started || _countdownTimer != null) return;
    HapticFeedback.selectionClick();
    setState(() => _countdown = 3);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        _countdownTimer = null;
        setState(() {
          _countdown = 0;
          _started = true;
        });
        _startCurrentPhase();
      }
    });
  }

  void _startCurrentPhase() {
    final phase = _phase;
    _phaseController
      ..duration = Duration(seconds: phase.seconds)
      ..reset()
      ..forward();
    HapticFeedback.selectionClick();
  }

  void _advancePhase() {
    if (!mounted || _completed) return;
    final finishedPhase = _phase;
    _elapsedBeforePhase += finishedPhase.seconds;

    var nextPhase = _phaseIndex + 1;
    var nextCycles = _completedCycles;
    if (nextPhase >= widget.exercise.phases.length) {
      nextPhase = 0;
      nextCycles++;
    }

    if (nextCycles >= widget.exercise.cycles) {
      HapticFeedback.mediumImpact();
      setState(() {
        _completedCycles = nextCycles;
        _completed = true;
        _advancing = false;
      });
      return;
    }

    setState(() {
      _phaseIndex = nextPhase;
      _completedCycles = nextCycles;
      _advancing = false;
    });
    _startCurrentPhase();
  }

  void _togglePause() {
    if (!_started || _completed) return;
    HapticFeedback.selectionClick();
    if (_paused) {
      _phaseController.forward();
    } else {
      _phaseController.stop();
    }
    setState(() => _paused = !_paused);
  }

  void _restart() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _phaseController.stop();
    setState(() {
      _phaseIndex = 0;
      _completedCycles = 0;
      _elapsedBeforePhase = 0;
      _countdown = 3;
      _started = false;
      _paused = false;
      _completed = false;
      _advancing = false;
    });
  }

  Future<void> _requestExit() async {
    if (!_started || _completed) {
      Navigator.of(context).pop();
      return;
    }

    final wasRunning = !_paused;
    if (wasRunning) {
      _phaseController.stop();
      setState(() => _paused = true);
    }

    final leave = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'End this exercise?',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'Your current breathing session will not be saved.',
              style: TextStyle(fontFamily: 'General Sans'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep breathing'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('End session'),
              ),
            ],
          ),
    );

    if (!mounted) return;
    if (leave == true) {
      setState(() => _allowExit = true);
      Navigator.of(context).pop();
    } else if (wasRunning) {
      _phaseController.forward();
      setState(() => _paused = false);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phaseController
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final safeSeconds = seconds.clamp(0, 35999);
    final minutes = (safeSeconds ~/ 60).toString().padLeft(2, '0');
    final remainder = (safeSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainder';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_started || _completed || _allowExit,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        backgroundColor: widget.exercise.color,
        body: SafeArea(
          child: _completed ? _buildCompletion() : _buildSession(),
        ),
      ),
    );
  }

  Widget _buildSession() {
    return AnimatedBuilder(
      animation: _phaseController,
      builder: (context, _) {
        final phaseProgress = _started ? _phaseController.value : 0.0;
        final easedProgress = Curves.easeInOut.transform(phaseProgress);
        final scale =
            _started
                ? _phase.startScale +
                    ((_phase.endScale - _phase.startScale) * easedProgress)
                : 0.62;
        final phaseRemaining =
            _started
                ? ((_phase.seconds * (1 - phaseProgress)).ceil()).clamp(
                  1,
                  _phase.seconds,
                )
                : 0;
        final elapsedInPhase =
            _started ? (_phase.seconds * phaseProgress).floor() : 0;
        final totalRemaining =
            widget.exercise.totalSeconds - _elapsedBeforePhase - elapsedInPhase;
        final totalProgress =
            widget.exercise.totalSeconds == 0
                ? 0.0
                : (1 - totalRemaining / widget.exercise.totalSeconds).clamp(
                  0.0,
                  1.0,
                );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 18, 20, 0),
              child: Row(
                children: [
                  CustomBackButton(
                    onPressed: _requestExit,
                    iconColor: Colors.white,
                    iconSize: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.exercise.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Quicksand',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatTime(totalRemaining),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'General Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: totalProgress,
                  minHeight: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child:
                      !_started
                          ? SizedBox(width: 310, child: _buildReadyState())
                          : _buildBreather(scale, phaseRemaining),
                ),
              ),
            ),
            if (_started) ...[
              Text(
                _paused ? 'Paused' : _phase.instruction,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cycle ${_completedCycles + 1} of ${widget.exercise.cycles}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontFamily: 'General Sans',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoundControl(
                    icon: Icons.refresh_rounded,
                    label: 'Restart',
                    onTap: _restart,
                  ),
                  const SizedBox(width: 18),
                  _RoundControl(
                    icon:
                        _paused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                    label: _paused ? 'Resume' : 'Pause',
                    onTap: _togglePause,
                    prominent: true,
                  ),
                  const SizedBox(width: 18),
                  _RoundControl(
                    icon: Icons.close_rounded,
                    label: 'End',
                    onTap: _requestExit,
                  ),
                ],
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 22, 28, 24),
              child: Text(
                'Keep it gentle · stop if you feel dizzy or uncomfortable',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.66),
                  fontFamily: 'General Sans',
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReadyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 230,
            child: SvgPicture.asset(
              widget.exercise.imageAsset,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _countdownTimer == null ? 'Ready when you are' : '$_countdown',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Quicksand',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _countdownTimer == null
                ? 'Settle your body and let your natural breath soften.'
                : 'Let your shoulders drop',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontFamily: 'General Sans',
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 26),
          if (_countdownTimer == null)
            SizedBox(
              width: 210,
              height: 48,
              child: ElevatedButton(
                onPressed: _beginCountdown,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: widget.exercise.color,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Begin',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBreather(double scale, int phaseRemaining) {
    final holding = _phase.isHold;
    return SizedBox(
      width: 310,
      height: 310,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: 0.88 + (scale * 0.16),
            child: Container(
              width: 268,
              height: 268,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 1.5,
                ),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.9 + (scale * 0.12),
            child: Container(
              width: 225,
              height: 225,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Transform.scale(
            scale: scale,
            child: Container(
              width: 205,
              height: 205,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.98),
                    Colors.white.withValues(alpha: 0.84),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 34,
                    spreadRadius: 4,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _paused ? 'PAUSED' : _phase.label.toUpperCase(),
                style: TextStyle(
                  color: widget.exercise.color,
                  fontFamily: 'General Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$phaseRemaining',
                style: TextStyle(
                  color: widget.exercise.color,
                  fontFamily: 'Quicksand',
                  fontSize: 54,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                holding ? 'stay soft' : 'seconds',
                style: TextStyle(
                  color: widget.exercise.color.withValues(alpha: 0.68),
                  fontFamily: 'General Sans',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletion() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CustomBackButton(
              onPressed: () => Navigator.of(context).pop(),
              iconColor: Colors.white,
              iconSize: 24,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 190,
            height: 190,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              'assets/images/Breathing exercise-cuate.svg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'You completed the practice.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Quicksand',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${widget.exercise.cycles} cycles of ${widget.exercise.title}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontFamily: 'General Sans',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Notice your breathing without changing it. Take a moment before returning to your day.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Quicksand',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: widget.exercise.color,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _restart,
            child: const Text(
              'Repeat exercise',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontFamily: 'General Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color color;

  const _GuidanceCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE3E0F8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF686579),
                    fontFamily: 'General Sans',
                    fontSize: 11.5,
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

class _RoundControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool prominent;

  const _RoundControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.prominent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: prominent ? 58 : 48,
            height: prominent ? 58 : 48,
            decoration: BoxDecoration(
              color:
                  prominent
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border:
                  prominent
                      ? null
                      : Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Icon(
              icon,
              color: prominent ? const Color(0xFF535394) : Colors.white,
              size: prominent ? 29 : 23,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'General Sans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
