import 'package:flutter/material.dart';
import 'package:ping_my_therapist/screens/journal_entry_screen.dart';
import 'package:ping_my_therapist/screens/journal_scratch_entry_screen.dart';
import 'package:ping_my_therapist/screens/saved_prompts_screen.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';
import 'package:ping_my_therapist/widgets/stretchy_section_page.dart';

class JournalingScreen extends StatelessWidget {
  const JournalingScreen({super.key});

  static const _prompts = [
    (
      'Values Check-in',
      'What values did I uphold today, and when did I stray?',
    ),
    (
      'Learning Corner',
      'What did I learn today about myself, others, or the world?',
    ),
    (
      'Anxiety Dialogue',
      "What could I accomplish if I weren't so anxious all the time?",
    ),
    ('Success Stories', "List three small achievements I'm proud of today"),
  ];

  static const _tips = [
    'Write without judging or editing your thoughts',
    'Focus on feelings, not just events.',
    'Start each entry by writing one word that describes today',
  ];

  @override
  Widget build(BuildContext context) {
    return StretchySectionPage(
      title: 'Reflect & renew',
      subtitle: 'A little space to untangle what is on your mind.',
      icon: Icons.auto_stories_outlined,
      leading: const Align(
        alignment: Alignment.centerLeft,
        child: CustomBackButton(iconColor: Colors.white, iconSize: 24),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _JournalActionCard(
            icon: Icons.edit_note_rounded,
            title: 'Write freely',
            description: 'Start with whatever is on your mind.',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JournalScratchEntryScreen(),
                  ),
                ),
          ),
          const SizedBox(height: 12),
          _JournalActionCard(
            icon: Icons.bookmarks_outlined,
            title: 'Your entries',
            description: 'Return to what you have written.',
            outlined: true,
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedPromptsScreen()),
                ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Need a place to start?',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF292735),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pick a prompt and follow the thought wherever it goes.',
            style: TextStyle(
              fontFamily: 'General Sans',
              fontSize: 13,
              color: Color(0xFF6F6B7D),
            ),
          ),
          const SizedBox(height: 18),
          for (var index = 0; index < _prompts.length; index++) ...[
            _PromptCard(
              index: index + 1,
              title: _prompts[index].$1,
              description: _prompts[index].$2,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => JournalEntryScreen(
                            prompt: _prompts[index].$1,
                            tips: _tips,
                          ),
                    ),
                  ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _JournalActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final bool outlined;

  const _JournalActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = outlined ? sectionPurple : Colors.white;
    return Material(
      color: outlined ? const Color(0xFFF7F6FF) : sectionPurple,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border:
                outlined ? Border.all(color: const Color(0xFFDCD8F1)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: foreground, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: foreground,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 12,
                        color: foreground.withValues(alpha: 0.84),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _PromptCard({
    required this.index,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDCD8F1)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBE9FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$index'.padLeft(2, '0'),
                  style: const TextStyle(
                    color: sectionPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF292735),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 12.5,
                        height: 1.4,
                        color: Color(0xFF6F6B7D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: sectionPurple,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
