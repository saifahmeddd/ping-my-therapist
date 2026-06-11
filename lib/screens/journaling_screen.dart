import 'package:flutter/material.dart';
import 'package:ping_my_therapist/screens/journal_entry_screen.dart';
import 'package:ping_my_therapist/screens/journal_scratch_entry_screen.dart';
import 'package:ping_my_therapist/screens/saved_prompts_screen.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

class JournalingScreen extends StatelessWidget {
  const JournalingScreen({super.key});

  static const List<Map<String, String>> _prompts = [
    {
      'title': 'Values Check-in',
      'desc': 'What values did I uphold today, and when did I stray?',
    },
    {
      'title': 'Learning Corner',
      'desc': 'What did I learn today about myself, others, or the world?',
    },
    {
      'title': 'Anxiety Dialogue',
      'desc': "What could I accomplish if I weren't so anxious all the time?",
    },
    {
      'title': 'Success Stories',
      'desc': "List three small achievements I'm proud of today",
    },
  ];

  static const List<String> _defaultTips = [
    'Write without judging or editing your thoughts',
    'Focus on feelings, not just events.',
    'Start each entry by writing one word that describes today',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  CustomBackButton(iconColor: Colors.black87, iconSize: 20),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reflect & Renew',
                        style: TextStyle(
                          fontFamily: 'quicksand',
                          fontWeight: FontWeight.w600,
                          fontSize: 32,
                          color: Colors.black,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const JournalScratchEntryScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Write from scratch'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7D7DDE),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'General Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SavedPromptsScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.bookmark_border, size: 18),
                          label: const Text('View Saved Prompts'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(
                              color: Color(0xFFB9B6F3),
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'General Sans',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Prompts',
                        style: TextStyle(
                          fontFamily: 'quicksand',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._prompts.map(
                        (prompt) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => JournalEntryScreen(
                                    prompt: prompt['title']!,
                                    tips: _defaultTips,
                                  ),
                                ),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFB9B6F3),
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            prompt['title']!,
                                            style: const TextStyle(
                                              fontFamily: 'quicksand',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            prompt['desc']!,
                                            style: const TextStyle(
                                              fontFamily: 'General Sans',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Colors.black87,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward,
                                      size: 22,
                                      color: Color(0xFF8C88F8),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
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
