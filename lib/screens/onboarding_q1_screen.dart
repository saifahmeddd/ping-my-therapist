import 'package:flutter/material.dart';
import 'package:ping_my_therapist/screens/onboarding_q2_screen.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

class OnboardingQuestionOneScreen extends StatefulWidget {
  const OnboardingQuestionOneScreen({super.key});

  @override
  State<OnboardingQuestionOneScreen> createState() =>
      _OnboardingQuestionOneScreenState();
}

class _OnboardingQuestionOneScreenState
    extends State<OnboardingQuestionOneScreen> {
  int _selectedValue = -1;

  final Map<int, String> _responses = {
    0: 'Reflect quietly',
    1: 'Reach out',
    2: 'Power through',
    3: 'Distract yourself',
  };

  void _saveResponseAndContinue() {
    if (_selectedValue == -1) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OnboardingQuestionTwoScreen(
              answer1: _responses[_selectedValue]!,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 186, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 24.0,
                      backgroundColor: Color(0xFFE5E5F8),
                      child: Text(
                        '1',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'quicksand',
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'When life gets overwhelming, you usually...',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'quicksand',
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 48.0),
                    Align(
                      alignment: Alignment.center,
                      child: _buildOption(index: 0, text: 'Reflect quietly'),
                    ),
                    const SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.center,
                      child: _buildOption(index: 1, text: 'Reach out'),
                    ),
                    const SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.center,
                      child: _buildOption(index: 2, text: 'Power through'),
                    ),
                    const SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.center,
                      child: _buildOption(index: 3, text: 'Distract yourself'),
                    ),
                    const SizedBox(height: 48.0),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 364,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              _selectedValue == -1
                                  ? null
                                  : _saveResponseAndContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7D7DDE),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Next',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontFamily: 'General Sans',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12.0,
              left: 3,
              child: CustomBackButton(iconColor: Colors.black87, iconSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({required int index, required String text}) {
    final bool isSelected = _selectedValue == index;
    const Color purple = Color(0xFF535394);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedValue = index;
        });
      },
      borderRadius: BorderRadius.circular(12.0),
      child: SizedBox(
        width: 364,
        height: 45,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? purple : Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border:
                isSelected
                    ? null
                    : Border.all(color: const Color(0xFFBBB3FF), width: 1),
            boxShadow:
                isSelected
                    ? []
                    : [
                      const BoxShadow(
                        color: Color(0x3D7B5CFA),
                        blurRadius: 0,
                        spreadRadius: 3,
                        offset: Offset(0, 0),
                      ),
                    ],
          ),
          child: Row(
            children: <Widget>[
              isSelected
                  ? const Icon(Icons.check, color: Colors.white)
                  : Container(
                    width: 15,
                    height: 15,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7D7DDE),
                      shape: BoxShape.circle,
                    ),
                  ),
              const SizedBox(width: 16.0),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13.0,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontFamily: 'General Sans',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
