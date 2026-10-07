import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';
import 'package:ping_my_therapist/screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  Map<String, dynamic>? _userData;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      if (mounted) {
        setState(() {
          _loading = true;
          _loadError = null;
        });
      }
      try {
        await user.reload();
      } on FirebaseAuthException {
        // The Firestore profile can still be shown if Auth refresh is offline.
      }
      final currentUser = FirebaseAuth.instance.currentUser ?? user;
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
      final data = doc.data() ?? <String, dynamic>{};
      final authEmail = currentUser.email;
      if (authEmail != null && authEmail != data['email']) {
        data['email'] = authEmail;
        try {
          await doc.reference.set({
            'email': authEmail,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (_) {
          // Auth remains the source of truth; retry synchronization on reload.
        }
      }
      if (mounted) setState(() => _userData = data);
    } catch (_) {
      if (mounted) setState(() => _loadError = 'Could not load your profile.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editProfile() async {
    final data = _userData;
    if (data == null) return;
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => EditProfileScreen(userData: data),
      ),
    );
    if (!mounted) return;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    _loadUserData();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    context.go(RouteNames.signup);
  }

  @override
  Widget build(BuildContext context) {
    final name = (_userData?['name'] as String?) ?? 'User';
    final email =
        FirebaseAuth.instance.currentUser?.email ??
        (_userData?['email'] as String?) ??
        'No email linked';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'quicksand',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.7,
                      color: Color(0xFF535394),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh profile',
                  onPressed: _loading ? null : _loadUserData,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF535394),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontFamily: 'quicksand',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                name,
                style: const TextStyle(
                  fontFamily: 'quicksand',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Center(
              child: Text(
                email,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'General Sans',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_loadError != null) ...[
              Text(_loadError!, textAlign: TextAlign.center),
              TextButton(onPressed: _loadUserData, child: const Text('Retry')),
            ],
            if (_userData != null) ...[
              _InfoTile(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: (_userData!['age'] ?? '—').toString(),
              ),
              const SizedBox(height: 12),
              _InfoTile(
                icon: Icons.work_outline,
                label: 'Occupation',
                value: (_userData!['occupation'] ?? '—').toString(),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _editProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'General Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF535394), size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'General Sans',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
