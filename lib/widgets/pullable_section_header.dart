import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:ping_my_therapist/widgets/stretchy_section_page.dart';

/// Home-style header for screens whose content scrolls independently.
class PullableSectionHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool compact;

  const PullableSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.compact = false,
  });

  @override
  State<PullableSectionHeader> createState() => _PullableSectionHeaderState();
}

class _PullableSectionHeaderState extends State<PullableSectionHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spring;

  @override
  void initState() {
    super.initState();
    _spring = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() {}));
  }

  void _release() {
    _spring.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 170, damping: 18),
        _spring.value,
        0,
        0,
      ),
    );
  }

  @override
  void dispose() {
    _spring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pull = _spring.value.clamp(0.0, 120.0);
    final titleSize = sectionHeaderTitleSize(MediaQuery.sizeOf(context).width);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        _spring.stop();
        _spring.value = (_spring.value + details.delta.dy * 0.7).clamp(
          0.0,
          120.0,
        );
      },
      onVerticalDragEnd: (_) => _release(),
      onVerticalDragCancel: _release,
      child: Container(
        key: const ValueKey('pullable-section-header'),
        width: double.infinity,
        padding:
            widget.compact
                ? EdgeInsets.fromLTRB(12, 8 + pull * 0.12, 12, 14 + pull * 0.55)
                : EdgeInsets.fromLTRB(
                  sectionHeaderSidePadding,
                  sectionHeaderTopPadding + pull * 0.12,
                  sectionHeaderSidePadding,
                  sectionHeaderBottomPadding + pull * 0.55,
                ),
        decoration: const BoxDecoration(
          color: sectionPurple,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child:
                widget.compact
                    ? Column(
                      children: [
                        Row(
                          children: [
                            if (widget.leading != null) widget.leading!,
                            Expanded(
                              child: Text(
                                widget.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (widget.trailing != null) widget.trailing!,
                          ],
                        ),
                        const SizedBox(height: 12),
                        _PullGrip(pull: pull),
                      ],
                    )
                    : Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.leading != null) ...[
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: widget.leading!,
                              ),
                              const SizedBox(width: sectionHeaderLeadingGap),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.7,
                                      height: 1.15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: sectionHeaderSubtitleGap,
                                  ),
                                  Text(
                                    widget.subtitle,
                                    style: const TextStyle(
                                      fontFamily: 'General Sans',
                                      fontSize: 12,
                                      height: 1.4,
                                      color: Color(0xE6FFFFFF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.trailing != null) ...[
                              const SizedBox(width: sectionHeaderLeadingGap),
                              widget.trailing!,
                            ],
                          ],
                        ),
                        const SizedBox(height: sectionHeaderGripGap),
                        _PullGrip(pull: pull),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}

class _PullGrip extends StatelessWidget {
  const _PullGrip({required this.pull});

  final double pull;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 34 + pull * 0.22,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(99),
      ),
    ),
  );
}
