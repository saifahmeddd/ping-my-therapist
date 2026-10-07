import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _occupationController;
  late final TextEditingController _emailController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.userData['name']?.toString() ?? '',
    );
    _ageController = TextEditingController(
      text: widget.userData['age']?.toString() ?? '',
    );
    _occupationController = TextEditingController(
      text: widget.userData['occupation']?.toString() ?? '',
    );
    _emailController = TextEditingController(
      text:
          FirebaseAuth.instance.currentUser?.email ??
          widget.userData['email']?.toString() ??
          '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<bool> _requestEmailChange(User user, String newEmail) async {
    try {
      await user.verifyBeforeUpdateEmail(newEmail);
      return true;
    } on FirebaseAuthException catch (error) {
      if (error.code != 'requires-recent-login') rethrow;
      if (!mounted || user.email == null) rethrow;

      final password = await showDialog<String>(
        context: context,
        builder: (_) => const _CurrentPasswordDialog(),
      );
      if (password == null || password.isEmpty) return false;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(
        newEmail,
      );
      return true;
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('Please sign in again to edit your profile.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final occupation = _occupationController.text.trim();
    final email = _emailController.text.trim();
    final emailChanged = email != (user.email ?? '');

    try {
      if (emailChanged && !await _requestEmailChange(user, email)) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'age': age,
        'occupation': occupation,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Keep the Auth display name aligned with the Firestore profile.
      try {
        await user.updateDisplayName(name);
      } on FirebaseAuthException {
        // The saved Firestore profile remains the source of truth.
      }

      if (!mounted) return;
      Navigator.of(context).pop(
        emailChanged
            ? 'Profile saved. Check your new email address to confirm the change.'
            : 'Profile updated.',
      );
    } on FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'invalid-email' => 'Please enter a valid email address.',
        'email-already-in-use' => 'That email address is already in use.',
        'wrong-password' ||
        'invalid-credential' => 'The current password was incorrect.',
        'requires-recent-login' => 'Please sign in again and retry.',
        'network-request-failed' => 'Check your connection and try again.',
        _ => 'Could not update your email. Please try again.',
      };
      _showMessage(message);
    } catch (_) {
      _showMessage('Could not save your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Your details',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF535394),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Keep your information current so your experience stays personal.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator:
                        (value) =>
                            (value?.trim().isEmpty ?? true)
                                ? 'Enter your name.'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      final age = int.tryParse(value?.trim() ?? '');
                      return age == null || age < 1 || age > 120
                          ? 'Enter a valid age.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _occupationController,
                    decoration: const InputDecoration(labelText: 'Occupation'),
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator:
                        (value) =>
                            (value?.trim().isEmpty ?? true)
                                ? 'Enter your occupation.'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    autocorrect: false,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      return RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(email)
                          ? null
                          : 'Enter a valid email address.';
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Changing your email sends a confirmation link to the new address.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child:
                        _saving
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Save Changes'),
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

class _CurrentPasswordDialog extends StatefulWidget {
  const _CurrentPasswordDialog();

  @override
  State<_CurrentPasswordDialog> createState() => _CurrentPasswordDialogState();
}

class _CurrentPasswordDialogState extends State<_CurrentPasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm it is you'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: true,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(labelText: 'Current password'),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
