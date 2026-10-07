import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';
import 'package:ping_my_therapist/widgets/stretchy_section_page.dart';
import 'package:ping_my_therapist/services/journal_entry_order.dart';

class SavedPromptsScreen extends StatelessWidget {
  const SavedPromptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: sectionPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'Your journal',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: const CustomBackButton(iconColor: Colors.white, iconSize: 24),
      ),
      body: SafeArea(
        child:
            user == null
                ? const Center(child: Text('You must be logged in.'))
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('journal_entries')
                          .where('userId', isEqualTo: user.uid)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      final error = snapshot.error;
                      final permissionDenied =
                          error is FirebaseException &&
                          error.code == 'permission-denied';
                      return _JournalState(
                        icon: Icons.cloud_off_outlined,
                        message:
                            permissionDenied
                                ? 'Your account cannot access these entries. Please sign in again and retry.'
                                : 'Could not load your entries. Check your connection and try again.',
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final entries =
                        snapshot.data!.docs.toList()..sort(
                          (a, b) => compareJournalEntries(a.data(), b.data()),
                        );
                    if (entries.isEmpty) {
                      return const _JournalState(
                        icon: Icons.auto_stories_outlined,
                        message:
                            'Your writing will appear here after you save an entry.',
                      );
                    }
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: entries.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final data = entries[index].data();
                            final prompt =
                                (data['prompt'] as String?) ?? 'Free write';
                            final title = prompt.split('\n').first;
                            final entry = (data['entry'] as String?) ?? '';
                            final timestamp = journalEntryDate(
                              data['timestamp'],
                            );
                            final date =
                                timestamp != null
                                    ? MaterialLocalizations.of(
                                      context,
                                    ).formatMediumDate(timestamp)
                                    : '';
                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap:
                                    () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (_) => _SavedEntryDetail(
                                              title: title,
                                              date: date,
                                              entry: entry,
                                            ),
                                      ),
                                    ),
                                child: Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFDCD8F1),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.menu_book_outlined,
                                        color: sectionPurple,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                            if (date.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                date,
                                                style: const TextStyle(
                                                  color: Color(0xFF6F6B7D),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                            if (entry.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                entry,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF6F6B7D),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
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
                          },
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}

class _JournalState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _JournalState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: sectionPurple),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'General Sans',
                fontSize: 14,
                color: Color(0xFF6F6B7D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedEntryDetail extends StatelessWidget {
  final String title;
  final String date;
  final String entry;
  const _SavedEntryDetail({
    required this.title,
    required this.date,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: sectionPurple,
        foregroundColor: Colors.white,
        title: const Text('Journal entry'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: sectionPurple,
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                  ),
                ),
                if (date.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    date,
                    style: const TextStyle(
                      fontFamily: 'General Sans',
                      color: Color(0xFF6F6B7D),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDCD8F1)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry,
                    style: const TextStyle(
                      fontFamily: 'General Sans',
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF292735),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
