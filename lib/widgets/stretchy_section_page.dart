import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const sectionPurple = Color(0xFF535394);
const sectionHeaderSidePadding = 20.0;
const sectionHeaderTopPadding = 12.0;
const sectionHeaderBottomPadding = 20.0;
const sectionHeaderLeadingGap = 6.0;
const sectionHeaderSubtitleGap = 6.0;
const sectionHeaderGripGap = 14.0;

double sectionHeaderTitleSize(double width) =>
    (width * 0.072).clamp(22.0, 28.0);

/// A single bouncing scroll surface with a header that follows a downward pull.
class StretchySectionPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final Widget? leading;
  final IconData? icon;
  final Widget? bottomAction;

  const StretchySectionPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    this.leading,
    this.icon,
    this.bottomAction,
  });

  @override
  State<StretchySectionPage> createState() => _StretchySectionPageState();
}

class _StretchySectionPageState extends State<StretchySectionPage> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = sectionHeaderTitleSize(width);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: sectionPurple,
        bottomNavigationBar:
            widget.bottomAction == null
                ? null
                : SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE8E6F8))),
                    ),
                    child: Center(
                      heightFactor: 1,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: widget.bottomAction,
                      ),
                    ),
                  ),
                ),
        body: SafeArea(
          bottom: false,
          child: ListView(
            controller: _controller,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final pull =
                      _controller.hasClients
                          ? (-_controller.offset).clamp(0.0, 120.0)
                          : 0.0;
                  return Container(
                    key: const ValueKey('stretchy-section-header'),
                    padding: EdgeInsets.fromLTRB(
                      sectionHeaderSidePadding,
                      sectionHeaderTopPadding + pull * 0.12,
                      sectionHeaderSidePadding,
                      sectionHeaderBottomPadding + pull * 0.55,
                    ),
                    decoration: const BoxDecoration(
                      color: sectionPurple,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
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
                                  const SizedBox(
                                    width: sectionHeaderLeadingGap,
                                  ),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.title,
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
                                if (widget.icon != null && width >= 400) ...[
                                  const SizedBox(width: 12),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      widget.icon,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: sectionHeaderGripGap),
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
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height * 0.68,
                ),
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: widget.content,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
