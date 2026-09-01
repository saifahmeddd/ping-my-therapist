import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ping_my_therapist/services/patient_link_service.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

class NameWhatYouFeelScreen extends StatefulWidget {
  const NameWhatYouFeelScreen({super.key});

  @override
  State<NameWhatYouFeelScreen> createState() => _NameWhatYouFeelScreenState();
}

class _NameWhatYouFeelScreenState extends State<NameWhatYouFeelScreen> {
  static const _purple = Color(0xFF535394);
  static const _primary = Color(0xFF7D7DDE);
  static const _lavender = Color(0xFFE5E5F8);
  static const _border = Color(0xFFD1C4E9);

  static const List<_MoodOption> _moods = [
    _MoodOption(
      label: 'Bright',
      reflection: 'Open, energized, or joyful',
      gifPath: 'assets/gifs/great.gif',
      iconPath: 'assets/emojis/mood-scale/great.svg',
      storedMood: 'Grounded & Growing',
    ),
    _MoodOption(
      label: 'Good',
      reflection: 'Steady, comfortable, or content',
      gifPath: 'assets/gifs/good.gif',
      iconPath: 'assets/emojis/mood-scale/good.svg',
      storedMood: 'Light & Clear',
    ),
    _MoodOption(
      label: 'Unsure',
      reflection: 'Mixed, distant, or hard to read',
      gifPath: 'assets/gifs/neutral-face.gif',
      iconPath: 'assets/emojis/mood-scale/so-so.svg',
      storedMood: 'Chaotic & Scattered',
    ),
    _MoodOption(
      label: 'Low',
      reflection: 'Heavy, tired, or discouraged',
      gifPath: 'assets/gifs/bad.gif',
      iconPath: 'assets/emojis/mood-scale/bad.svg',
      storedMood: 'Cloudy & Low',
    ),
    _MoodOption(
      label: 'Overwhelmed',
      reflection: 'Frustrated, tense, or at capacity',
      gifPath: 'assets/gifs/pouting-face.gif',
      iconPath: 'assets/emojis/mood-scale/very-bad.svg',
      storedMood: 'Heavy & Drowning',
    ),
  ];

  static const Map<String, List<_EmotionOption>> _emotionGroups = {
    'Stressed': [
      _EmotionOption(
        label: 'Anxious',
        assetPath: 'assets/emojis/stressed/Anxious face with sweat.svg',
      ),
      _EmotionOption(
        label: 'Nervous',
        assetPath: 'assets/emojis/stressed/Sad but relieved face.svg',
      ),
      _EmotionOption(
        label: 'Insecure',
        assetPath: 'assets/emojis/stressed/Face in clouds.svg',
      ),
      _EmotionOption(
        label: 'Burnt out',
        assetPath: 'assets/emojis/stressed/Knocked-out face.svg',
      ),
      _EmotionOption(
        label: 'Overwhelmed',
        assetPath: 'assets/emojis/others/stressed.svg',
      ),
    ],
    'Low': [
      _EmotionOption(
        label: 'Sad',
        assetPath: 'assets/emojis/annoyance/Pensive face.svg',
      ),
      _EmotionOption(
        label: 'Tired',
        assetPath: 'assets/emojis/annoyance/Tired face.svg',
      ),
      _EmotionOption(label: 'Numb', assetPath: 'assets/emojis/others/Numb.svg'),
      _EmotionOption(label: 'Low', assetPath: 'assets/emojis/others/Low.svg'),
      _EmotionOption(
        label: 'Unmotivated',
        assetPath: 'assets/emojis/energy/Sleepy face.svg',
      ),
    ],
    'Activated': [
      _EmotionOption(
        label: 'Annoyed',
        assetPath: 'assets/emojis/annoyance/Unamused face.svg',
      ),
      _EmotionOption(
        label: 'Frustrated',
        assetPath: 'assets/emojis/annoyance/Confounded face.svg',
      ),
      _EmotionOption(
        label: 'Angry',
        assetPath: 'assets/emojis/annoyance/Pouting face.svg',
      ),
      _EmotionOption(
        label: 'Restless',
        assetPath: 'assets/emojis/vibes/Face with rolling eyes.svg',
      ),
      _EmotionOption(
        label: 'Thoughtful',
        assetPath: 'assets/emojis/vibes/Thinking face.svg',
      ),
    ],
    'Positive': [
      _EmotionOption(
        label: 'Happy',
        assetPath: 'assets/emojis/positive/happy.svg',
      ),
      _EmotionOption(
        label: 'Grateful',
        assetPath: 'assets/emojis/positive/grateful.svg',
      ),
      _EmotionOption(
        label: 'Hopeful',
        assetPath: 'assets/emojis/positive/Face exhaling.svg',
      ),
      _EmotionOption(
        label: 'Confident',
        assetPath: 'assets/emojis/positive/Smiling face with sunglasses.svg',
      ),
      _EmotionOption(
        label: 'Loved',
        assetPath: 'assets/emojis/others/loved.svg',
      ),
    ],
    'Energized': [
      _EmotionOption(
        label: 'Excited',
        assetPath: 'assets/emojis/energy/Grinning face with big eyes.svg',
      ),
      _EmotionOption(
        label: 'Inspired',
        assetPath: 'assets/emojis/energy/Star-struck.svg',
      ),
      _EmotionOption(
        label: 'Focused',
        assetPath: 'assets/emojis/energy/Nerd face.svg',
      ),
      _EmotionOption(
        label: 'Energetic',
        assetPath: 'assets/emojis/energy/Beaming face with smiling eyes.svg',
      ),
      _EmotionOption(
        label: 'Playful',
        assetPath: 'assets/emojis/vibes/Winking face with tongue.svg',
      ),
    ],
  };

  static const List<String> _influences = [
    'Relationships',
    'Work or study',
    'Sleep',
    'Health',
    'Change or uncertainty',
    'Something I remembered',
    'I am not sure yet',
  ];

  final TextEditingController _noteController = TextEditingController();
  final Set<String> _selectedEmotions = {};
  final Set<String> _selectedInfluences = {};

  int _step = 0;
  int _selectedMood = 2;
  String _selectedGroup = 'Stressed';
  bool _saving = false;
  bool _complete = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_complete || _step == 0) {
      Navigator.of(context).pop();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _step--);
  }

  void _nextStep() {
    if (_step == 1 && _selectedEmotions.isEmpty) {
      _showMessage('Choose at least one feeling that fits.');
      return;
    }
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();
    setState(() => _step++);
  }

  void _toggleEmotion(String emotion) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedEmotions.contains(emotion)) {
        _selectedEmotions.remove(emotion);
      } else if (_selectedEmotions.length < 4) {
        _selectedEmotions.add(emotion);
      } else {
        _showMessage('Four feelings are enough for this check-in.');
      }
    });
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);

    final mood = _moods[_selectedMood];
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final therapistUid = await PatientLinkService().getTherapistUid();
        final payload = <String, dynamic>{
          'userId': user.uid,
          'moods': [mood.storedMood],
          'displayMood': mood.label,
          'moodScale': _selectedMood + 1,
          'emotions': _selectedEmotions.toList(),
          'factors': _selectedInfluences.toList(),
          'source': 'name_what_you_feel',
          'timestamp': FieldValue.serverTimestamp(),
        };
        final note = _noteController.text.trim();
        if (note.isNotEmpty) payload['note'] = note;
        if (therapistUid != null) payload['therapistUid'] = therapistUid;

        await FirebaseFirestore.instance
            .collection('mood_checkins')
            .add(payload);
      } catch (_) {
        // Reflection remains useful offline; saving should not block completion.
      }
    }

    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _saving = false;
      _complete = true;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _purple,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder:
                      (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.04, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                  child:
                      _complete
                          ? _buildCompletion()
                          : _buildStep(key: ValueKey(_step)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 22, 24),
      child: Row(
        children: [
          CustomBackButton(
            onPressed: _goBack,
            iconColor: Colors.white,
            iconSize: 24,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name What You Feel',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Quicksand',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'A quiet moment to understand what is here.',
                  style: TextStyle(
                    color: Color(0xFFE9E9FF),
                    fontFamily: 'General Sans',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!_complete)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_step + 1} of 3',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'General Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep({required Key key}) {
    switch (_step) {
      case 0:
        return _buildMoodStep(key);
      case 1:
        return _buildEmotionStep(key);
      default:
        return _buildInfluenceStep(key);
    }
  }

  Widget _buildMoodStep(Key key) {
    final mood = _moods[_selectedMood];
    return Column(
      key: key,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StepHeading(
                  eyebrow: 'START BROAD',
                  title: 'Which face feels closest?',
                  subtitle:
                      'Do not overthink it. Pick the expression that matches this moment best.',
                ),
                const SizedBox(height: 18),
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: Container(
                      key: ValueKey(mood.gifPath),
                      width: 180,
                      height: 180,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withValues(alpha: 0.14),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(mood.gifPath, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Column(
                    children: [
                      Text(
                        mood.label,
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        mood.reflection,
                        style: const TextStyle(
                          color: Color(0xFF77738A),
                          fontFamily: 'General Sans',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: List.generate(_moods.length, (index) {
                    final option = _moods[index];
                    final selected = index == _selectedMood;
                    return Expanded(
                      child: Semantics(
                        button: true,
                        selected: selected,
                        label: option.label,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedMood = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: EdgeInsets.only(
                              right: index == _moods.length - 1 ? 0 : 7,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? _lavender : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: selected ? _primary : _border,
                                width: selected ? 2 : 1.2,
                              ),
                            ),
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  option.iconPath,
                                  width: 31,
                                  height: 31,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  option.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'General Sans',
                                    fontSize: 9,
                                    fontWeight:
                                        selected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                    color:
                                        selected
                                            ? const Color(0xFF42427D)
                                            : const Color(0xFF77738A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        _BottomAction(label: 'Find the words', onPressed: _nextStep),
      ],
    );
  }

  Widget _buildEmotionStep(Key key) {
    final emotions = _emotionGroups[_selectedGroup]!;
    return Column(
      key: key,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepHeading(
                  eyebrow: 'GET SPECIFIC',
                  title: 'Give the feeling a name',
                  subtitle:
                      _selectedEmotions.isEmpty
                          ? 'Choose up to four words. More than one feeling can be true.'
                          : '${_selectedEmotions.length} selected · tap again to remove',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 37,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _emotionGroups.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final group = _emotionGroups.keys.elementAt(index);
                      final selected = group == _selectedGroup;
                      return ChoiceChip(
                        label: Text(group),
                        selected: selected,
                        onSelected:
                            (_) => setState(() => _selectedGroup = group),
                        showCheckmark: false,
                        selectedColor: _purple,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: selected ? _purple : _border),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontFamily: 'General Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 20) / 3;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          emotions.map((emotion) {
                            final selected = _selectedEmotions.contains(
                              emotion.label,
                            );
                            return _EmotionCard(
                              width: width,
                              emotion: emotion,
                              selected: selected,
                              onTap: () => _toggleEmotion(emotion.label),
                            );
                          }).toList(),
                    );
                  },
                ),
                if (_selectedEmotions.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F5FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What you are holding right now',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children:
                              _selectedEmotions
                                  .map(
                                    (emotion) => InputChip(
                                      label: Text(emotion),
                                      onDeleted: () => _toggleEmotion(emotion),
                                      backgroundColor: Colors.white,
                                      deleteIconColor: _primary,
                                      side: const BorderSide(color: _border),
                                      labelStyle: const TextStyle(
                                        fontFamily: 'General Sans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        _BottomAction(
          label: 'Make sense of it',
          onPressed: _nextStep,
          enabled: _selectedEmotions.isNotEmpty,
        ),
      ],
    );
  }

  Widget _buildInfluenceStep(Key key) {
    return Column(
      key: key,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StepHeading(
                  eyebrow: 'NOTICE THE CONTEXT',
                  title: 'What might be influencing it?',
                  subtitle:
                      'You do not need a perfect answer. Noticing is already useful.',
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 9,
                  runSpacing: 10,
                  children:
                      _influences.map((influence) {
                        final selected = _selectedInfluences.contains(
                          influence,
                        );
                        return FilterChip(
                          label: Text(influence),
                          selected: selected,
                          onSelected: (_) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              selected
                                  ? _selectedInfluences.remove(influence)
                                  : _selectedInfluences.add(influence);
                            });
                          },
                          showCheckmark: true,
                          checkmarkColor: Colors.white,
                          selectedColor: _purple,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: selected ? _purple : _border),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontFamily: 'General Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Anything else you want to name?',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Optional · a sentence or even one word is enough',
                  style: TextStyle(
                    color: Color(0xFF77738A),
                    fontFamily: 'General Sans',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 280,
                  style: const TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 14,
                    height: 1.45,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Right now, I notice...',
                    hintStyle: const TextStyle(color: Color(0xFFAAA7B9)),
                    filled: true,
                    fillColor: const Color(0xFFF7F6FF),
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _BottomAction(
          label: _saving ? 'Saving your reflection...' : 'Complete check-in',
          onPressed: _finish,
          enabled: !_saving,
          showProgress: _saving,
        ),
      ],
    );
  }

  Widget _buildCompletion() {
    final mood = _moods[_selectedMood];
    final needsCalm =
        _selectedMood >= 2 ||
        _selectedEmotions.any(
          const {'Anxious', 'Overwhelmed', 'Angry', 'Frustrated'}.contains,
        );
    final suggestionTitle =
        needsCalm ? 'Give your body a little calm' : 'Hold onto this awareness';
    final suggestionText =
        needsCalm
            ? 'A short breathing exercise can help your nervous system settle.'
            : 'Writing a few lines can help you remember what supported this feeling.';
    final suggestionRoute =
        needsCalm ? RouteNames.exercises : RouteNames.journaling;

    return SingleChildScrollView(
      key: const ValueKey('complete'),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
      child: Column(
        children: [
          Container(
            width: 138,
            height: 138,
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8EF),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(mood.gifPath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'You made space for it.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 27,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Naming a feeling does not make it bigger. It makes it easier to understand.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF686579),
              fontFamily: 'General Sans',
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feeling ${mood.label.toLowerCase()}',
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children:
                      _selectedEmotions
                          .map(
                            (emotion) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                emotion,
                                style: const TextStyle(
                                  color: Color(0xFF535394),
                                  fontFamily: 'General Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => context.pushReplacement(suggestionRoute),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      needsCalm
                          ? 'assets/icons/heartbeat.svg'
                          : 'assets/icons/book-open-text.svg',
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestionTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Quicksand',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          suggestionText,
                          style: const TextStyle(
                            color: Color(0xFFE5E5F8),
                            fontFamily: 'General Sans',
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: _border, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Return home',
                style: TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const _StepHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: Color(0xFF7D7DDE),
            fontFamily: 'General Sans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF686579),
            fontFamily: 'General Sans',
            fontSize: 12.5,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _BottomAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool showProgress;

  const _BottomAction({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 49,
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7D7DDE),
            disabledBackgroundColor: const Color(0xFFD8D7EA),
            foregroundColor: Colors.white,
            elevation: enabled ? 3 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showProgress) ...[
                const SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!showProgress) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 19),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmotionCard extends StatelessWidget {
  final double width;
  final _EmotionOption emotion;
  final bool selected;
  final VoidCallback onTap;

  const _EmotionCard({
    required this.width,
    required this.emotion,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: emotion.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.03 : 1,
          duration: const Duration(milliseconds: 160),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: width,
            height: 105,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE5E5F8) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    selected
                        ? const Color(0xFF7D7DDE)
                        : const Color(0xFFD1C4E9),
                width: selected ? 2 : 1.2,
              ),
              boxShadow:
                  selected
                      ? [
                        BoxShadow(
                          color: const Color(
                            0xFF7D7DDE,
                          ).withValues(alpha: 0.13),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ]
                      : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        emotion.assetPath,
                        width: 43,
                        height: 43,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          emotion.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:
                                selected
                                    ? const Color(0xFF42427D)
                                    : Colors.black87,
                            fontFamily: 'General Sans',
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Positioned(
                    top: 7,
                    right: 7,
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF7D7DDE),
                      size: 17,
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

class _MoodOption {
  final String label;
  final String reflection;
  final String gifPath;
  final String iconPath;
  final String storedMood;

  const _MoodOption({
    required this.label,
    required this.reflection,
    required this.gifPath,
    required this.iconPath,
    required this.storedMood,
  });
}

class _EmotionOption {
  final String label;
  final String assetPath;

  const _EmotionOption({required this.label, required this.assetPath});
}
