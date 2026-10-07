import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/screens/breathing_exercises_screen.dart';
import 'package:ping_my_therapist/screens/mood_tracker_screen.dart';
import 'package:ping_my_therapist/screens/profile_screen.dart';

const _homeHeaderColor = Color(0xFF535394);

class HomePage extends StatefulWidget {
  final int initialIndex;
  final List<Widget>? tabScreens;

  const HomePage({super.key, this.initialIndex = 0, this.tabScreens});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  late final Set<int> _visitedIndexes;

  List<Widget> get _screens =>
      widget.tabScreens ??
      [
        _HomeContent(onOpenTracker: () => _onItemTapped(1)),
        const MoodTrackerScreen(),
        const BreathingExercisesScreen(showBackButton: false),
        const ProfileScreen(),
      ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, _screens.length - 1);
    _visitedIndexes = {_selectedIndex};
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _selectedIndex = widget.initialIndex.clamp(0, _screens.length - 1);
      _visitedIndexes.add(_selectedIndex);
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        _visitedIndexes.add(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final usesDarkHeader = _selectedIndex != 3;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectedIndex != 0) _onItemTapped(0);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor:
              _selectedIndex == 0 ? _homeHeaderColor : Colors.transparent,
          statusBarIconBrightness:
              usesDarkHeader ? Brightness.light : Brightness.dark,
          statusBarBrightness:
              usesDarkHeader ? Brightness.dark : Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: IndexedStack(
            index: _selectedIndex,
            children: List.generate(
              _screens.length,
              (index) =>
                  _visitedIndexes.contains(index)
                      ? _screens[index]
                      : const SizedBox.shrink(),
            ),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE8E6F8))),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1435355F),
                  blurRadius: 18,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: NavigationBar(
                key: const ValueKey('primary-navigation'),
                height: 70,
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onItemTapped,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                indicatorColor: const Color(0xFFEBE9FF),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: const [
                  NavigationDestination(
                    icon: _NavIcon(assetName: 'house.svg'),
                    selectedIcon: _NavIcon(
                      assetName: 'house-fill.svg',
                      selected: true,
                    ),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: _NavIcon(assetName: 'smiley.svg'),
                    selectedIcon: _NavIcon(
                      assetName: 'smiley-fill.svg',
                      selected: true,
                    ),
                    label: 'Tracker',
                  ),
                  NavigationDestination(
                    icon: _NavIcon(assetName: 'heartbeat.svg'),
                    selectedIcon: _NavIcon(
                      assetName: 'heartbeat-fill.svg',
                      selected: true,
                    ),
                    label: 'Exercises',
                  ),
                  NavigationDestination(
                    icon: _NavIcon(assetName: 'user-circle.svg'),
                    selectedIcon: _NavIcon(
                      assetName: 'user-circle-fill.svg',
                      selected: true,
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final String assetName;
  final bool selected;

  const _NavIcon({required this.assetName, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/nav-icons/$assetName',
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        selected ? const Color(0xFF6868B9) : const Color(0xFF8C8998),
        BlendMode.srcIn,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Home content
// ─────────────────────────────────────────────
class _HomeContent extends StatefulWidget {
  final VoidCallback onOpenTracker;

  const _HomeContent({required this.onOpenTracker});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String? _userName;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc =
          await FirebaseFirestore.instance
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final headingSize = (screenWidth * 0.082).clamp(25.0, 32.0);

    return ColoredBox(
      color: _homeHeaderColor,
      child: SafeArea(
        bottom: false,
        child: ListView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            // ── Header ──────────────────────────────────────
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, _) {
                final pull =
                    _scrollController.hasClients
                        ? (-_scrollController.offset).clamp(0.0, 120.0)
                        : 0.0;
                return Container(
                  key: const ValueKey('home-header'),
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: 28 + pull * 0.12,
                    left: 20,
                    right: 20,
                    bottom: 38 + pull * 0.55,
                  ),
                  decoration: const BoxDecoration(
                    color: _homeHeaderColor,
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: headingSize,
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
                      const SizedBox(height: 24),
                      Center(
                        child: Container(
                          width: 34 + pull * 0.22,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // ── Cards ────────────────────────────────────────
            Container(
              width: double.infinity,
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
                    onTap: () => context.push(RouteNames.chatbot),
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
                    border: Border.all(
                      color: const Color(0xFFD1C4E9),
                      width: 2,
                    ),
                    onTap: () => context.push(RouteNames.exercises),
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
                    onTap: () => context.push(RouteNames.journaling),
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
                    border: Border.all(
                      color: const Color(0xFFD1C4E9),
                      width: 2,
                    ),
                    onTap: () => context.push(RouteNames.journaling),
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
                    onTap: widget.onOpenTracker,
                  ),

                  const Text(
                    'Coping Tools',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name what you feel
                  _FeatureTile(
                    text:
                        "Slow down, find the right words, and make sense of what is showing up.",
                    label: 'Name What You Feel',
                    svgPath: 'assets/images/self-love.svg',
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    labelColor: Colors.black,
                    iconColor: Colors.black,
                    imageLeft: true,
                    border: Border.all(
                      color: const Color(0xFFD1C4E9),
                      width: 2,
                    ),
                    onTap: () => context.push(RouteNames.nameWhatYouFeel),
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
                    border: Border.all(
                      color: const Color(0xFFD1C4E9),
                      width: 2,
                    ),
                    onTap: () => context.push(RouteNames.music),
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
                    onTap: () => context.push(RouteNames.appointments),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 350;
        final imageSize = (constraints.maxWidth * 0.27).clamp(72.0, 122.0);
        final gap = compact ? 10.0 : 16.0;

        return Semantics(
          button: true,
          label: widget.label,
          child: GestureDetector(
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
                constraints: BoxConstraints(minHeight: compact ? 176 : 196),
                margin: const EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(compact ? 16 : 20),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: widget.border,
                ),
                child: Row(
                  children: [
                    if (widget.imageLeft) ...[
                      SvgPicture.asset(
                        widget.svgPath,
                        height: imageSize,
                        width: imageSize,
                      ),
                      SizedBox(width: gap),
                    ],
                    Expanded(child: _textContent()),
                    if (!widget.imageLeft) ...[
                      SizedBox(width: gap),
                      SvgPicture.asset(
                        widget.svgPath,
                        height: imageSize,
                        width: imageSize,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.labelColor,
                  fontSize: 14,
                  letterSpacing: -0.5,
                ),
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
