import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ping_my_therapist/core/layout/device_layout.dart';

class SplashIllustration extends StatelessWidget {
  const SplashIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final size = context.w(313);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(35),
                context.h(55),
                context.w(35),
                context.h(64),
              ),
              child: SvgPicture.asset(
                'assets/images/illustrations/splash_bg.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(30),
                context.h(75),
                context.w(29),
                context.h(12),
              ),
              child: SvgPicture.asset(
                'assets/images/illustrations/splash_plants.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(80),
                context.h(17),
                context.w(48),
                context.h(14),
              ),
              child: SvgPicture.asset(
                'assets/images/illustrations/splash_character.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignupIllustration extends StatelessWidget {
  const SignupIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.w(340),
      height: context.h(260),
      child: SvgPicture.asset(
        'assets/images/illustrations/signup_scene.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}
