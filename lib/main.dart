import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ping_my_therapist/core/app_strings.dart';
import 'package:ping_my_therapist/firebase_options.dart';
import 'package:ping_my_therapist/screens/splash_screen.dart';
import 'package:ping_my_therapist/screens/chatbot_screen.dart';
import 'package:ping_my_therapist/screens/journaling_screen.dart';
import 'package:ping_my_therapist/screens/breathing_exercises_screen.dart';
import 'package:ping_my_therapist/screens/mood_checkin_screen.dart';
import 'package:ping_my_therapist/screens/appointment_screen.dart';
import 'package:ping_my_therapist/screens/music_recommendation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env (ignore if missing in dev)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MoodieApp());
}

class MoodieApp extends StatelessWidget {
  const MoodieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Quicksand',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
      routes: {
        '/chatbot': (_) => const ChatbotScreen(),
        '/journaling': (_) => const JournalingScreen(),
        '/exercises': (_) => const BreathingExercisesScreen(),
        '/mood': (_) => const MoodCheckinScreen(),
        '/appointments': (_) => const AppointmentScreen(),
        '/music': (_) => const MusicRecommendationScreen(),
      },
    );
  }
}
