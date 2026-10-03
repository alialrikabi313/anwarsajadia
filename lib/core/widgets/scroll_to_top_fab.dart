// زر عائم للعودة إلى أعلى الصفحات الطويلة (ومعه فتح الفهرس إن وُجد).

import 'package:flutter/material.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

/// يظهر بعد نزول [showAfter] بكسل ويختفي قبلها. حين تُمرَّر [onOpenIndex]
/// يظهر زران: «الفهرس» يفتح لوحة الأقسام، و«أعلى» يرجع لرأس الصفحة.
class ScrollToTopFab extends StatefulWidget {
  const ScrollToTopFab({
    required this.controller,
    this.onOpenIndex,
    this.showAfter = 400,
    super.key,
  });

  final ScrollController controller;
  final VoidCallback? onOpenIndex;
  final double showAfter;

  @override
  State<ScrollToTopFab> createState() => _ScrollToTopFabState();
}

class _ScrollToTopFabState extends State<ScrollToTopFab> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!widget.controller.hasClients) return;
    final show = widget.controller.offset > widget.showAfter;
    if (show != _visible && mounted) setState(() => _visible = show);
  }

  void _toTop() {
    widget.controller.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      offset: _visible ? Offset.zero : const Offset(0, 1.4),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: _visible ? 1 : 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onOpenIndex != null) ...[
              _MiniFab(
                icon: Icons.list_alt_rounded,
                tooltip: 'الفهرس',
                onTap: _visible ? widget.onOpenIndex! : null,
              ),
              const SizedBox(height: 10),
            ],
            _MiniFab(
              icon: Icons.keyboard_arrow_up_rounded,
              tooltip: 'أعلى الصفحة',
              onTap: _visible ? _toTop : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniFab extends StatelessWidget {
  const _MiniFab({required this.icon, required this.tooltip, this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primary,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: AppColors.accentGold, size: 26),
          ),
        ),
      ),
    );
  }
}

/// لوحة أقسام منسدلة: «أعلى الصفحة» ثم كل الأقسام — للقفز المباشر بينها.
Future<void> showSectionIndexSheet(
  BuildContext context, {
  required List<String> titles,
  required void Function(int index) onSelect,
  required VoidCallback onTop,
  String title = 'الفهرس',
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
              child: Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontFamilyFallback: kArabicFontFallback,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onTop();
                    },
                    icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 20),
                    label: const Text(
                      'أعلى الصفحة',
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                itemCount: titles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  leading: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentGold,
                    ),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    titles[i],
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontFamilyFallback: kArabicFontFallback,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onSelect(i);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
