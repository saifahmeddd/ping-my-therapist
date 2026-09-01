import 'package:flutter/material.dart';
import 'package:ping_my_therapist/screens/onboarding_q3_screen.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

class OnboardingQuestionTwoScreen extends StatefulWidget {
  final String answer1;

  const OnboardingQuestionTwoScreen({super.key, required this.answer1});

  @override
  State<OnboardingQuestionTwoScreen> createState() =>
      _OnboardingQuestionTwoScreenState();
}

class _OnboardingQuestionTwoScreenState
    extends State<OnboardingQuestionTwoScreen> {
  int _selectedValue = -1;

  final Map<int, String> _responses = {
    0: 'Personal growth',
    1: 'Helping others',
    2: 'Achieving goals',
    3: 'Finding balance',
  };

  void _saveResponseAndContinue() {
    if (_selectedValue == -1) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OnboardingQuestionThreeScreen(
              answer1: widget.answer1,
              answer2: _responses[_selectedValue]!,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 126.0,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 24.0,
                    backgroundColor: Color(0xFFE5E5F8),
                    child: Text(
                      '2',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'quicksand',
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'What motivates you the most right now?',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'quicksand',
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 48.0),
                  Align(
                    alignment: Alignment.center,
                    child: _buildOption(index: 0, text: 'Personal growth'),
                  ),
                  const SizedBox(height: 12.0),
                  Align(
                    alignment: Alignment.center,
                    child: _buildOption(index: 1, text: 'Helping others'),
                  ),
                  const SizedBox(height: 12.0),
                  Align(
                    alignment: Alignment.center,
                    child: _buildOption(index: 2, text: 'Achieving goals'),
                  ),
                  const SizedBox(height: 12.0),
                  Align(
                    alignment: Alignment.center,
                    child: _buildOption(index: 3, text: 'Finding balance'),
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
    );
  }

  Widget _buildOption({required int index, required String text}) {
    final bool isSelected = _selectedValue == index;

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
            color: isSelected ? const Color(0xFF535394) : Colors.white,
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
