import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ping_my_therapist/core/app_strings.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';

class SignupLoginScreen extends StatelessWidget {
  const SignupLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 60),
            Text(
              'Welcome to ${AppStrings.appName}',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'quicksand',
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This is your space—create an account to keep your check-ins private and available whenever you need them.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 30),
            SvgPicture.asset(
              'assets/images/Enthusiastic-pana.svg',
              height: 364,
              width: 364,
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: 364,
              height: 45,
              child: ElevatedButton(
                onPressed: () => context.push(RouteNames.enterInfo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C84F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Create an account',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: 364,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.push(RouteNames.login),
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  backgroundColor: const Color(0xFFF8F7FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontFamily: 'General Sans',
                    color: Color(0xFF2B2930),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
