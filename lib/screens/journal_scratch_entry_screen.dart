import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ping_my_therapist/services/patient_link_service.dart';
import 'package:ping_my_therapist/widgets/journal_editor_layout.dart';

class JournalScratchEntryScreen extends StatefulWidget {
  final Future<void> Function(String entry)? saveEntry;

  const JournalScratchEntryScreen({super.key, this.saveEntry});

  @override
  State<JournalScratchEntryScreen> createState() =>
      _JournalScratchEntryScreenState();
}

class _JournalScratchEntryScreenState extends State<JournalScratchEntryScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  static const _tips = [
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
    if (_saving) return;
    final user =
        widget.saveEntry == null ? FirebaseAuth.instance.currentUser : null;
    if (widget.saveEntry == null && user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save entries.')),
      );
      return;
    }
    final entryText = _controller.text.trim();
    if (entryText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry cannot be empty.')));
      return;
    }
    setState(() => _saving = true);
    try {
      if (widget.saveEntry case final save?) {
        await save(entryText);
      } else {
        final therapistUid = await PatientLinkService().getTherapistUid();
        final payload = <String, dynamic>{
          'userId': user!.uid,
          'entry': entryText,
          'timestamp': FieldValue.serverTimestamp(),
        };
        if (therapistUid != null) payload['therapistUid'] = therapistUid;
        await FirebaseFirestore.instance
            .collection('journal_entries')
            .add(payload);
      }
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entry saved!')));
      _controller.clear();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JournalEditorLayout(
      title: "What's on your mind today?",
      subtitle: 'A private place to write whatever you need to let out.',
      tips: _tips,
      controller: _controller,
      onSave: _saveEntry,
      isSaving: _saving,
    );
  }
}
