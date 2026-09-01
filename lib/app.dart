import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ping_my_therapist/core/router/app_router.dart';
import 'package:ping_my_therapist/core/app_strings.dart';
import 'package:ping_my_therapist/theme/app_theme.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: AppStrings.appName,
      routerConfig: router,
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
    );
  }
}
