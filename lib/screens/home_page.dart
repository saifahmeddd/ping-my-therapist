import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ping_my_therapist/screens/breathing_exercises_screen.dart';
import 'package:ping_my_therapist/screens/mood_tracker_screen.dart';
import 'package:ping_my_therapist/screens/profile_screen.dart';
import 'package:ping_my_therapist/screens/appointment_screen.dart';
import 'package:ping_my_therapist/screens/music_recommendation_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _HomeContent(),
    MoodTrackerScreen(),
    BreathingExercisesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _selectedIndex == 0
                    ? 'assets/icons/nav-icons/house-fill.svg'
                    : 'assets/icons/nav-icons/house.svg',
                height: 28,
                width: 28,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 0
                      ? const Color(0xFF7D7DDE)
                      : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _selectedIndex == 1
                    ? 'assets/icons/nav-icons/smiley-fill.svg'
                    : 'assets/icons/nav-icons/smiley.svg',
                height: 28,
                width: 28,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 1
                      ? const Color(0xFF7D7DDE)
                      : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Tracker',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _selectedIndex == 2
                    ? 'assets/icons/nav-icons/heartbeat-fill.svg'
                    : 'assets/icons/nav-icons/heartbeat.svg',
                height: 28,
                width: 28,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 2
                      ? const Color(0xFF7D7DDE)
                      : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Exercises',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _selectedIndex == 3
                    ? 'assets/icons/nav-icons/user-circle-fill.svg'
                    : 'assets/icons/nav-icons/user-circle.svg',
                height: 28,
                width: 28,
                colorFilter: ColorFilter.mode(
                  _selectedIndex == 3
                      ? const Color(0xFF7D7DDE)
                      : Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF7D7DDE),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 8,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Home content
// ─────────────────────────────────────────────
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() => _userName = (doc.data()?['name'] as String?) ?? 'User');
      }
    } catch (_) {
      if (mounted) setState(() => _userName = 'User');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const _SoftBouncingScrollPhysics(),
      children: [
        // ── Header ──────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 52,
            left: 20,
            right: 20,
            bottom: 80,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF535394),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Welcome, ${_userName ?? 'there'}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '"Your mind matters. Every day, in every way."',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // ── Cards ────────────────────────────────────────
        Transform.translate(
          offset: const Offset(0, -60),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recommended for today',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Chatbot
                _FeatureTile(
                  text:
                      "You don't have to hold it all alone. Let's talk or write it out",
                  label: 'Chat with Nova',
                  svgPath: 'assets/images/robot.svg',
                  backgroundColor: const Color(0xFF2A2A4A),
                  textColor: Colors.white,
                  labelColor: Colors.white,
                  iconColor: Colors.white,
                  imageRight: true,
                  onTap: () => Navigator.pushNamed(context, '/chatbot'),
                ),

                const Text(
                  'Take a deep breath',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Breathing
                _FeatureTile(
                  text:
                      "Let's calm your system - start with a few mindful breaths",
                  label: 'Exercises',
                  svgPath: 'assets/images/meditation.svg',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  labelColor: Colors.black,
                  iconColor: Colors.black,
                  imageLeft: true,
                  border: Border.all(color: const Color(0xFFD1C4E9), width: 2),
                  onTap: () => Navigator.pushNamed(context, '/exercises'),
                ),

                const Text(
                  'Explore yourself',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Journaling
                _FeatureTile(
                  text:
                      "When thoughts feel tangled, writing them out can bring clarity.",
                  label: 'Journaling',
                  svgPath: 'assets/images/writing.svg',
                  backgroundColor: const Color(0xFFE5E5F8),
                  textColor: Colors.black,
                  labelColor: Colors.black,
                  iconColor: Colors.black,
                  imageRight: true,
                  onTap: () => Navigator.pushNamed(context, '/journaling'),
                ),

                const Text(
                  'Daily Prompts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Prompts
                _FeatureTile(
                  text:
                      "Get inspired with a new reflection or writing prompt today.",
                  label: 'Prompts',
                  svgPath: 'assets/images/prompt.svg',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  labelColor: Colors.black,
                  iconColor: Colors.black,
                  imageLeft: true,
                  border: Border.all(color: const Color(0xFFD1C4E9), width: 2),
                  onTap: () => Navigator.pushNamed(context, '/journaling'),
                ),

                const Text(
                  'Mood Check-In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Mood
                _FeatureTile(
                  text:
                      "Check in with how you feel. Awareness is the first step.",
                  label: 'Mood Tracker',
                  svgPath: 'assets/images/mood.svg',
                  backgroundColor: const Color(0xFFE5E5F8),
                  textColor: Colors.black,
                  labelColor: Colors.black,
                  iconColor: Colors.black,
                  imageRight: true,
                  onTap: () => Navigator.pushNamed(context, '/mood'),
                ),

                const Text(
                  'Music Therapy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Music recommendations
                _FeatureTile(
                  text:
                      'Let music meet your mood. Songs and playlists picked for how you feel.',
                  label: 'Mood Music',
                  svgPath: 'assets/images/serene.svg',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  labelColor: Colors.black,
                  iconColor: Colors.black,
                  imageLeft: true,
                  border:
                      Border.all(color: const Color(0xFFD1C4E9), width: 2),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MusicRecommendationScreen(),
                    ),
                  ),
                ),

                const Text(
                  'Book a Session',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Appointments
                _FeatureTile(
                  text:
                      "Browse verified therapists and book your next session.",
                  label: 'Appointments',
                  svgPath: 'assets/images/growing.svg',
                  backgroundColor: const Color(0xFF2A2A4A),
                  textColor: Colors.white,
                  labelColor: Colors.white,
                  iconColor: Colors.white,
                  imageRight: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppointmentScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Reusable animated feature tile
// ─────────────────────────────────────────────
class _FeatureTile extends StatefulWidget {
  final String text;
  final String label;
  final String svgPath;
  final Color backgroundColor;
  final Color textColor;
  final Color labelColor;
  final Color iconColor;
  final VoidCallback onTap;
  final bool imageRight;
  final bool imageLeft;
  final BoxBorder? border;

  const _FeatureTile({
    required this.text,
    required this.label,
    required this.svgPath,
    required this.backgroundColor,
    required this.textColor,
    required this.labelColor,
    required this.iconColor,
    required this.onTap,
    this.imageRight = false,
    this.imageLeft = false,
    this.border,
  });

  @override
  State<_FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<_FeatureTile> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: 220,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: widget.border,
          ),
          child: Row(
            children: widget.imageLeft
                ? [
                    SvgPicture.asset(
                      widget.svgPath,
                      height: 130,
                      width: 130,
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _textContent()),
                  ]
                : [
                    Expanded(child: _textContent()),
                    const SizedBox(width: 16),
                    SvgPicture.asset(
                      widget.svgPath,
                      height: widget.label == 'Journaling' ? 150 : 130,
                      width: widget.label == 'Journaling' ? 150 : 130,
                    ),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _textContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.text,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'General Sans',
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
            color: widget.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.labelColor,
                fontSize: 14,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: widget.iconColor, size: 18),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Soft scroll physics
// ─────────────────────────────────────────────
class _SoftBouncingScrollPhysics extends BouncingScrollPhysics {
  const _SoftBouncingScrollPhysics({super.parent});

  @override
  _SoftBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _SoftBouncingScrollPhysics(parent: buildParent(ancestor));

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) =>
      super.applyBoundaryConditions(position, value) * 0.4;
}
