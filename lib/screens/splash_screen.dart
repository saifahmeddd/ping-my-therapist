import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ping_my_therapist/core/app_strings.dart';
import 'package:ping_my_therapist/screens/signup_login_screen.dart';
import 'package:ping_my_therapist/screens/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _handleGetStarted() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final onboardingDoc = await FirebaseFirestore.instance
          .collection('onboarding_responses')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => onboardingDoc.exists
              ? const HomePage()
              : const SignupLoginScreen(),
        ),
      );
      return;
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignupLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7D7DDE),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'quicksand',
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Stay in touch—with yourself',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'quicksand',
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 64.0),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/growth2.svg',
                    height: 313,
                    width: 313,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Center(
                child: SizedBox(
                  width: 314,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      elevation: 3,
                    ),
                    onPressed: _handleGetStarted,
                    child: const Text(
                      'Get Started',
                      style: TextStyle(
                        color: Color(0xFF2B2930),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'GeneralSans',
                      ),
                    ),
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
