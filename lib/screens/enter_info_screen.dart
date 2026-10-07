import 'package:flutter/material.dart';
import 'package:ping_my_therapist/screens/email_pw_screen.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';

class EnterInfoScreen extends StatefulWidget {
  const EnterInfoScreen({super.key});

  @override
  State<EnterInfoScreen> createState() => _EnterInfoScreenState();
}

class _EnterInfoScreenState extends State<EnterInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();
  final FocusNode _occupationFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _nameFocus.dispose();
    _ageFocus.dispose();
    _occupationFocus.dispose();
    super.dispose();
  }

  void _goToEmailPasswordScreen() {
    String name = _nameController.text.trim();
    String age = _ageController.text.trim();
    String occupation = _occupationController.text.trim();

    if (name.isEmpty || age.isEmpty || occupation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EmailPasswordScreen(
              name: name,
              age: age,
              occupation: occupation,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      height: keyboardVisible ? 56.0 : 160.0,
                    ),
                    const Text(
                      'Tell us about yourself',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontFamily: 'quicksand',
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'We\'ll use this information to personalise your experience and ensure you get suggestions suited to you.',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.black,
                        fontFamily: 'General Sans',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 44.0),
                    const Text(
                      'First, what should we call you?',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontFamily: 'General Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      hintText: 'Jerry',
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _ageFocus.requestFocus(),
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'How old are you?',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontFamily: 'General Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    _buildTextField(
                      controller: _ageController,
                      focusNode: _ageFocus,
                      hintText: '19',
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _occupationFocus.requestFocus(),
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'What do you do?',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontFamily: 'General Sans',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    _buildTextField(
                      controller: _occupationController,
                      focusNode: _occupationFocus,
                      hintText: 'Student, Engineer, Artist...',
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),
                    const SizedBox(height: 4.0),
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16.0,
                          color: Colors.black38,
                        ),
                        SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            'Knowing what you do helps us understand what you\'re balancing',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF5B616D),
                              fontFamily: 'General Sans',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF7D7DDE),
                          borderRadius: BorderRadius.circular(6.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _goToEmailPasswordScreen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: TextStyle(
                                  fontFamily: 'General Sans',
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12.0,
              left: 3,
              child: CustomBackButton(iconColor: Colors.black87, iconSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    required TextInputAction textInputAction,
    required ValueChanged<String> onSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        scrollPadding: const EdgeInsets.only(bottom: 24),
        style: const TextStyle(
          fontFamily: 'General Sans',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF8C929C),
            fontFamily: 'General Sans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            letterSpacing: 0,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 12.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Color(0xFFBBB3FF), width: 2.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
    );
  }
}
