import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ping_my_therapist/core/router/route_names.dart';

class SuccessScreen extends StatefulWidget {
  final Map<String, dynamic> userAnswers;
  final Future<void> Function(Map<String, dynamic> answers)? saveAnswers;

  const SuccessScreen({super.key, required this.userAnswers, this.saveAnswers});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  bool _isSaving = false;
  bool _saveFailed = false;

  @override
  void initState() {
    super.initState();
    _saveDataToFirebase();
  }

  Future<void> _saveDataToFirebase() async {
    setState(() {
      _isSaving = true;
      _saveFailed = false;
    });

    try {
      if (widget.saveAnswers case final save?) {
        await save(widget.userAnswers);
      } else {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) throw Exception('No user signed in');

        final batch = FirebaseFirestore.instance.batch();

        // Save onboarding responses (read by chatbot for personalisation)
        final responsesRef = FirebaseFirestore.instance
            .collection('onboarding_responses')
            .doc(currentUser.uid);
        batch.set(responsesRef, {
          'uid': currentUser.uid,
          'answers': widget.userAnswers,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Mark onboarding complete on user profile
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid);
        batch.set(userRef, {
          'onboarding_complete': true,
        }, SetOptions(merge: true));

        await batch.commit();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saveFailed = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your answers. Please retry.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isSaving)
                const CircularProgressIndicator()
              else ...[
                const Text(
                  'That was brave.\nWell Done!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'quicksand',
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 24.0),
                SvgPicture.asset(
                  'assets/images/Self confidence-pana.svg',
                  height: 324,
                  width: 324,
                ),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _saveFailed
                            ? _saveDataToFirebase
                            : () => context.go(RouteNames.mood),
                    icon: const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      _saveFailed ? 'Retry saving' : 'Start Your Journey',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        fontFamily: 'General Sans',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7D7DDE),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
