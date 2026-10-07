import 'package:flutter/material.dart';
import 'package:ping_my_therapist/widgets/custom_back_button.dart';
import 'package:ping_my_therapist/widgets/stretchy_section_page.dart';

class JournalEditorLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> tips;
  final TextEditingController controller;
  final VoidCallback onSave;
  final bool isSaving;

  const JournalEditorLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tips,
    required this.controller,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
      appBar: AppBar(
        backgroundColor: sectionPurple,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: const CustomBackButton(iconColor: Colors.white, iconSize: 24),
        title: const Text(
          'Journal',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: sectionPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF6F6B7D),
                  ),
                ),
                if (tips.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        tips
                            .map(
                              (tip) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFDCD8F1),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    fontFamily: 'General Sans',
                                    fontSize: 11,
                                    color: Color(0xFF6F6B7D),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  enabled: !isSaving,
                  minLines: 12,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                    fontFamily: 'General Sans',
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF292735),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Start writing here…',
                    hintStyle: const TextStyle(color: Color(0xFF9994AA)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFFDCD8F1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: sectionPurple,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: isSaving ? null : onSave,
              icon:
                  isSaving
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.bookmark_add_outlined),
              label: Text(isSaving ? 'Saving…' : 'Save entry'),
              style: FilledButton.styleFrom(
                backgroundColor: sectionPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
