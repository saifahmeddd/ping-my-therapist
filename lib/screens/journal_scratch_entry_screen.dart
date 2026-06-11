import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ping_my_therapist/services/patient_link_service.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

class JournalScratchEntryScreen extends StatefulWidget {
  const JournalScratchEntryScreen({super.key});

  @override
  State<JournalScratchEntryScreen> createState() =>
      _JournalScratchEntryScreenState();
}

class _JournalScratchEntryScreenState
    extends State<JournalScratchEntryScreen> {
  final TextEditingController _controller = TextEditingController();

  static const List<String> _tips = [
    'Write without judging or editing your thoughts',
    'Focus on feelings, not just events.',
    'Start each entry by writing one word that describes today',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save entries.')),
      );
      return;
    }
    final entryText = _controller.text.trim();
    if (entryText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry cannot be empty.')),
      );
      return;
    }
    try {
      final therapistUid = await PatientLinkService().getTherapistUid();

      final payload = <String, dynamic>{
        'userId': user.uid,
        'entry': entryText,
        'timestamp': FieldValue.serverTimestamp(),
      };
      if (therapistUid != null) {
        payload['therapistUid'] = therapistUid;
      }

      await FirebaseFirestore.instance
          .collection('journal_entries')
          .add(payload);
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry saved!')),
      );
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FA),
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
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "What's on your mind today?",
                        style: TextStyle(
                          fontFamily: 'quicksand',
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ..._tips.map(
                        (tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 3, right: 8),
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: Color(0xFF7D7DDE),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    fontFamily: 'General Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black87,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _controller,
                        minLines: 12,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Start writing your thoughts here...',
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontFamily: 'General Sans',
                          fontSize: 14,
                          color: Colors.black,
                          letterSpacing: 0.2,
                        ),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(22),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _saveEntry,
            icon: const Icon(Icons.bookmark_border),
            label: const Text('Save Entry', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7D7DDE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: const TextStyle(
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
