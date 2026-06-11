import 'package:flutter/material.dart';
import 'package:ping_my_therapist/screens/mood_checkin_screen.dart';

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Mood Tracker',
                style: TextStyle(
                  fontFamily: 'quicksand',
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.7,
                  color: Color(0xFF535394),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track how you feel every day.',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.sentiment_satisfied_alt_outlined,
                            size: 64,
                            color: Color(0xFF535394),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "How are you feeling today?",
                            style: TextStyle(
                              fontFamily: 'quicksand',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MoodCheckinScreen(),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF535394),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'General Sans',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            child: const Text('Check In Now'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
