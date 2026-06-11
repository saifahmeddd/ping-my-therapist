import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ping_my_therapist/screens/box_breathing_step_screen.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

class BoxBreathingWalkthroughScreen extends StatefulWidget {
  const BoxBreathingWalkthroughScreen({super.key});

  @override
  State<BoxBreathingWalkthroughScreen> createState() =>
      _BoxBreathingWalkthroughScreenState();
}

class _BoxBreathingWalkthroughScreenState
    extends State<BoxBreathingWalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static final List<_PageData> _pages = [
    _PageData(
      backgroundColor: Colors.white,
      textColor: Colors.black,
      content:
          'Inhale, hold, exhale, hold—each for 4 seconds. A calming rhythm to centre your mind.',
      imageAsset: 'assets/images/nature-benefits.svg',
      imageHeight: 255,
      imageWidth: 406,
    ),
    _PageData(
      backgroundColor: const Color(0xFFB8B8FF),
      textColor: Colors.white,
      content: '• Inhale through your nose for 4 seconds\n'
          '• Hold your breath for 4 seconds\n'
          '• Exhale slowly through your mouth for 4 seconds\n'
          '• Hold your breath again for 4 seconds\n'
          '• Repeat this cycle for 4 minutes',
      imageAsset: 'assets/images/serene.svg',
      imageHeight: 342,
      imageWidth: 364,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              ..._pages.map((data) => _buildSimplePage(context, data)),
              _buildProTipPage(context),
              _buildEnvironmentPage(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimplePage(BuildContext context, _PageData data) {
    final isLast = _currentPage == _getTotalPages() - 1;
    return GestureDetector(
      onTap: isLast ? null : _nextPage,
      child: Container(
        color: data.backgroundColor,
        child: Stack(
          children: [
            Positioned(
              top: 48,
              left: 8,
              child: CustomBackButton(
                iconColor: data.textColor,
                iconSize: 24,
                onPressed: () {
                  if (_currentPage == 0) {
                    Navigator.of(context).pop();
                  } else {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    data.content,
                    style: TextStyle(
                      color: data.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: data.imageHeight,
                  width: data.imageWidth,
                  child: SvgPicture.asset(
                    data.imageAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Tap anywhere to continue',
                  style: TextStyle(
                    color: data.textColor.withValues(alpha: 0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Quicksand',
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProTipPage(BuildContext context) {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        color: const Color(0xFF39346B),
        child: Stack(
          children: [
            Positioned(
              top: 48,
              left: 8,
              child: CustomBackButton(
                iconColor: Colors.white,
                iconSize: 24,
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    height: 394,
                    width: 358,
                    child: SvgPicture.asset(
                      'assets/images/Meditation-pana.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Pro Tip',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Maintain a steady pace; visualise tracing a square with each phase.',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Tap anywhere to continue',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Quicksand',
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentPage(BuildContext context) {
    return Container(
      color: const Color(0xFF28254A),
      child: Stack(
        children: [
          Positioned(
            top: 48,
            left: 8,
            child: CustomBackButton(
              iconColor: Colors.white,
              iconSize: 24,
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 148),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Environment',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Sit upright in a quiet space with minimal distractions',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  height: 349,
                  width: 349,
                  child: SvgPicture.asset(
                    'assets/images/Breathing exercise-cuate.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: SizedBox(
                    width: 348,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF28254A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BoxBreathingStepScreen(
                              totalSeconds: 240,
                            ),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Let's Start",
                            style: TextStyle(
                              fontFamily: 'General Sans',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _getTotalPages() => _pages.length + 2;
}

class _PageData {
  final Color backgroundColor;
  final Color textColor;
  final String content;
  final String imageAsset;
  final double imageHeight;
  final double imageWidth;

  const _PageData({
    required this.backgroundColor,
    required this.textColor,
    required this.content,
    required this.imageAsset,
    required this.imageHeight,
    required this.imageWidth,
  });
}
