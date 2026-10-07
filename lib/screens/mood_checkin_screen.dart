import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/services/patient_link_service.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';
import 'package:ping_my_therapist/widgets/stretchy_section_page.dart';

class MoodCheckinScreen extends StatefulWidget {
  final bool returnToTracker;
  final Future<void> Function(List<String> moods)? saveCheckin;

  const MoodCheckinScreen({
    super.key,
    this.returnToTracker = false,
    this.saveCheckin,
  });

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen> {
  static const _moodIcons = [
    Icons.sentiment_satisfied_alt_rounded,
    Icons.blur_on_rounded,
    Icons.spa_rounded,
    Icons.sentiment_very_dissatisfied_rounded,
    Icons.sentiment_dissatisfied_rounded,
    Icons.psychology_alt_rounded,
  ];

  final List<Map<String, String>> _moodOptions = [
    {
      'label': 'Light & Clear',
      'description': 'Feeling okay, balanced, calm',
      'icon': 'assets/icons/cloud-sun-light.svg',
    },
    {
      'label': 'Chaotic & Scattered',
      'description': 'Distracted, stressed, messy mind',
      'icon': 'assets/icons/head-circuit-light.svg',
    },
    {
      'label': 'Grounded & Growing',
      'description': 'Hopeful, improving, intentional',
      'icon': 'assets/icons/leaf-light.svg',
    },
    {
      'label': 'Heavy & Drowning',
      'description': 'Overwhelmed, stuck, emotional',
      'icon': 'assets/icons/cloud-rain-light.svg',
    },
    {
      'label': 'Cloudy & Low',
      'description': 'Unmotivated, sad, flat',
      'icon': 'assets/icons/Vector.svg',
    },
    {
      'label': 'Wired & On edge',
      'description': 'Anxious, overthinking, restless',
      'icon': 'assets/icons/fire-light.svg',
    },
  ];

  final List<int> _selectedMoods = [];
  bool _leaving = false;
  bool _saving = false;

  void _returnToTracker() {
    if (!mounted || _leaving || _saving) return;
    _leaving = true;
    context.go('${RouteNames.home}?tab=tracker');
  }

  void _toggleMood(int index) {
    setState(() {
      if (_selectedMoods.contains(index)) {
        _selectedMoods.remove(index);
      } else {
        _selectedMoods.add(index);
      }
    });
  }

  Future<void> _navigateToHomePage() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final selectedLabels =
          _selectedMoods.map((i) => _moodOptions[i]['label']!).toList();
      if (widget.saveCheckin case final save?) {
        await save(selectedLabels);
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw StateError('Not signed in');
        final therapistUid = await PatientLinkService().getTherapistUid();
        final payload = <String, dynamic>{
          'userId': user.uid,
          'moods': selectedLabels,
          'timestamp': FieldValue.serverTimestamp(),
        };
        if (therapistUid != null) payload['therapistUid'] = therapistUid;
        await FirebaseFirestore.instance
            .collection('mood_checkins')
            .add(payload);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save your check-in. Please try again.'),
          ),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    context.go(
      widget.returnToTracker
          ? '${RouteNames.home}?tab=tracker'
          : RouteNames.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _returnToTracker();
      },
      child: StretchySectionPage(
        title: 'How are you feeling?',
        subtitle: 'Check in with yourself, one feeling at a time.',
        icon: Icons.favorite_border_rounded,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: CustomBackButton(
            onPressed: _returnToTracker,
            iconColor: Colors.white,
            iconSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose what fits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: sectionPurple,
                fontFamily: 'Quicksand',
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select one or more. You can always check in again later.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6F6B7D),
                fontFamily: 'General Sans',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            for (var index = 0; index < _moodOptions.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMoodOptionCard(
                  _moodOptions[index],
                  _selectedMoods.contains(index),
                  index,
                ),
              ),
          ],
        ),
        bottomAction: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed:
                _saving
                    ? null
                    : () {
                      if (_selectedMoods.isNotEmpty) {
                        _navigateToHomePage();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select at least one mood.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
            style: FilledButton.styleFrom(
              backgroundColor: sectionPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child:
                _saving
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save check-in'),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodOptionCard(
    Map<String, String> mood,
    bool isSelected,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _toggleMood(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        constraints: const BoxConstraints(minHeight: 76),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBE9FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? sectionPurple : const Color(0xFFDCD8F1),
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFF2F0FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(_moodIcons[index], color: sectionPurple, size: 23),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    mood['label'] ?? 'Label',
                    style: const TextStyle(
                      fontFamily: 'General Sans',
                      letterSpacing: 0,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    mood['description'] ?? 'Description',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'General Sans',
                      letterSpacing: 0,
                      color: Color(0xFF6F6B7D),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: sectionPurple),
          ],
        ),
      ),
    );
  }
}
