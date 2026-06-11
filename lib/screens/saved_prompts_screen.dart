import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

class SavedPromptsScreen extends StatelessWidget {
  const SavedPromptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
              child: CustomBackButton(iconColor: Colors.black87, iconSize: 28),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                'Revisit saved prompts',
                style: TextStyle(
                  fontFamily: 'quicksand',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: user == null
                  ? const Center(child: Text('You must be logged in.'))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('journal_entries')
                          .where('userId', isEqualTo: user.uid)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF7D7DDE),
                            ),
                          );
                        }
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No saved entries yet.\nStart journaling to see them here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'General Sans',
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          );
                        }

                        final entries = snapshot.data!.docs;
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final data = entries[index].data()
                                as Map<String, dynamic>;
                            final prompt =
                                (data['prompt'] as String?) ?? 'Free write';
                            final promptTitle = prompt.split('\n').first;
                            final ts =
                                data['timestamp'] as Timestamp?;
                            String dateStr = '';
                            if (ts != null) {
                              final d = ts.toDate();
                              dateStr =
                                  '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: const Color(0xFFBFC6FF),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                title: Text(
                                  promptTitle,
                                  style: const TextStyle(
                                    fontFamily: 'quicksand',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: dateStr.isNotEmpty
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8),
                                        child: Text(
                                          dateStr,
                                          style: const TextStyle(
                                            fontFamily: 'quicksand',
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                    : null,
                                trailing: const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF7D7DDE),
                                  size: 28,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
