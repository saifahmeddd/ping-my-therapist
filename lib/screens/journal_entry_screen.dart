import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ping_my_therapist/services/patient_link_service.dart';
import 'package:ping_my_therapist/widgets/journal_editor_layout.dart';

class JournalEntryScreen extends StatefulWidget {
  final String prompt;
  final List<String> tips;
  final Future<void> Function(String entry)? saveEntry;

  const JournalEntryScreen({
    super.key,
    required this.prompt,
    required this.tips,
    this.saveEntry,
  });

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _saving = false;

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
          'prompt': widget.prompt,
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JournalEditorLayout(
      title: widget.prompt,
      subtitle: 'Take your time. There is no right way to answer.',
      tips: widget.tips,
      controller: _controller,
      onSave: _saveEntry,
      isSaving: _saving,
    );
  }
}
