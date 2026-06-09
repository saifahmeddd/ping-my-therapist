import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ping_my_therapist/core/layout/device_layout.dart';
import 'package:ping_my_therapist/theme/app_colors.dart';
import 'package:ping_my_therapist/theme/app_text_styles.dart';

class MoodieTextField extends StatefulWidget {
  const MoodieTextField({
    super.key,
    required this.label,
    this.controller,
    this.placeholder,
    this.keyboardType,
    this.hint,
    this.hintIconAsset,
    this.initiallyFocused = false,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? placeholder;
  final TextInputType? keyboardType;
  final String? hint;
  final String? hintIconAsset;
  final bool initiallyFocused;
  final ValueChanged<String>? onChanged;

  @override
  State<MoodieTextField> createState() => _MoodieTextFieldState();
}

class _MoodieTextFieldState extends State<MoodieTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focused = widget.initiallyFocused;
    _focusNode.addListener(_handleFocusChange);
    if (widget.initiallyFocused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _handleFocusChange() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.fieldLabel),
        SizedBox(height: context.h(6)),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _focused ? AppColors.white : AppColors.inputBackground,
            borderRadius: context.radius(16),
            border: Border.all(
              color: _focused ? AppColors.primary : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            style: AppTextStyles.fieldInput,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: AppTextStyles.fieldInput.copyWith(
                color: AppColors.textHint,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.w(16),
                vertical: context.h(14),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (widget.hint != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              if (widget.hintIconAsset != null) ...[
                SvgPicture.asset(
                  widget.hintIconAsset!,
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(widget.hint!, style: AppTextStyles.fieldHint),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
