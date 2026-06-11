import 'package:flutter/material.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

class BoxBreathingStepScreen extends StatefulWidget {
  final int totalSeconds;
  const BoxBreathingStepScreen({super.key, this.totalSeconds = 240});

  @override
  State<BoxBreathingStepScreen> createState() => _BoxBreathingStepScreenState();
}

class _BoxBreathingStepScreenState extends State<BoxBreathingStepScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late int _remainingSeconds;
  late String _displayTime;
  int _currentStep = 0;
  bool _completed = false;

  static const List<String> _instructions = [
    'Inhale through your nose for 4 seconds.',
    'Hold your breath for 4 seconds.',
    'Exhale slowly through your mouth for 4 seconds.',
    'Hold your breath again for 4 seconds.',
  ];

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
    _displayTime = _formatTime(_remainingSeconds);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _remainingSeconds--;
        _displayTime = _formatTime(_remainingSeconds);
        if (_remainingSeconds > 0 && _remainingSeconds % 4 == 0) {
          _currentStep = (_currentStep + 1) % _instructions.length;
        }
        if (_remainingSeconds == 0) _completed = true;
      });
      return _remainingSeconds > 0;
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B88E7),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 16,
              left: 8,
              child: CustomBackButton(
                iconColor: Colors.white,
                iconSize: 24,
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              ),
            ),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, _) => CustomPaint(
                painter: _CirclesPainter(scale: _scaleAnimation.value),
                size: MediaQuery.of(context).size,
              ),
            ),
            Positioned(
              top: 64,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  _displayTime,
                  style: const TextStyle(
                    fontSize: 56,
                    color: Colors.white,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
            ),
            if (!_completed)
              Positioned(
                bottom: 120,
                left: 24,
                right: 24,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    child: Text(
                      _instructions[_currentStep],
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            if (_completed)
              Card(
                color: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
                elevation: 8,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                  child: Text(
                    'Great job!\nYou completed 4 minutes of Box Breathing.',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CirclesPainter extends CustomPainter {
  final double scale;
  _CirclesPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.6);
    for (int i = 3; i >= 1; i--) {
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08 * i);
      canvas.drawCircle(center, size.width * 0.25 * i * scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CirclesPainter old) => old.scale != scale;
}
