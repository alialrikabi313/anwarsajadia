// ويدجتس نظام التصميم المشتركة، مبنية حرفياً على إطارات فيغما (أرقام الإطارات
// مذكورة بجنب كل قياس). هنا الشكل فقط — أي منطق يمرّ بالمعاملات وردود النداء،
// حتى تبقى هذي الويدجتس قابلة للاستعمال بأي شاشة.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_decorations.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────
// رقاقات تبويب (مثل: الصحيفة | رسالة الحقوق)
// ─────────────────────────────────────────────────────────────────────
class FigmaPillTabs extends StatelessWidget {
  const FigmaPillTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.scrollable = true,
    super.key,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final children = List<Widget>.generate(tabs.length, (i) {
      final selected = i == selectedIndex;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => onChanged(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: selected
                ? AppDecorations.pillSelected
                : AppDecorations.pill.copyWith(
                    border: Border.all(
                      color: AppColors.borderLight.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
            child: Text(
              tabs[i],
              style: AppTextStyles.sectionTab.copyWith(
                color: selected
                    ? Colors.white
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ),
      );
    });

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: children),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// عنصر القائمة القياسي (أيقونة + عنوان + بيانات) — يتكرر بقوائم السجادية
// والمكتبة والوسائط.
// ─────────────────────────────────────────────────────────────────────
/// نص مع إبراز أصفر لكل ورود [query] داخل [text]. يرجّع نصاً عادياً إذا كان
/// [query] فارغاً. مطابقة حرفية لا مطبَّعة: النتائج هنا جاية أصلاً من بحث طبّع
/// النص، فالمطابقة بهذي المرحلة تكون على النص كما هو.
Widget highlightedText(
  String text,
  String? query,
  TextStyle style, {
  int maxLines = 1,
  TextAlign textAlign = TextAlign.start,
}) {
  final q = query?.trim() ?? '';
  if (q.isEmpty || !text.contains(q)) {
    return Text(text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign);
  }
  final spans = <TextSpan>[];
  var start = 0;
  while (true) {
    final i = text.indexOf(q, start);
    if (i < 0) {
      spans.add(TextSpan(text: text.substring(start)));
      break;
    }
    if (i > start) spans.add(TextSpan(text: text.substring(start, i)));
    spans.add(TextSpan(
      text: text.substring(i, i + q.length),
      style: const TextStyle(
        backgroundColor: AppColors.searchHighlight,
        color: Colors.black,
        fontWeight: FontWeight.w700,
      ),
    ));
    start = i + q.length;
  }
  return Text.rich(
    TextSpan(style: style, children: spans),
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    textAlign: textAlign,
  );
}

class FigmaListItem extends StatelessWidget {
  const FigmaListItem({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    this.background,
    this.highlight,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final Color? background;

  /// لمّا ما يكون فارغاً، ورود هذا النص داخل [title] تنبرز.
  final String? highlight;

  @override
  Widget build(BuildContext context) {
    // فيغما 191:5793 إطار 37: مقاس 377×45، حشو #D9D7CB، نصف قطر 25،
    // والنص Inter/11/w600 أسود مع فاصل رأسي أسود.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: background ?? AppColors.parchment,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Icon(
                  leadingIcon ?? Icons.menu_book_outlined,
                  size: 23,
                  color: AppColors.blackPure,
                ),
                const SizedBox(width: 10),
                Container(
                  width: 0.8,
                  height: 12,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: highlightedText(
                    title,
                    highlight,
                    const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  Container(
                    width: 0.8,
                    height: 12,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Container(
                  width: 0.8,
                  height: 12,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onFavoriteTap,
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 17,
                    color: isFavorite
                        ? AppColors.charcoal
                        : Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// بطاقة البطل (خطبة أو قصة): صورة بالجنب + عنوان مزخرف + متن
// ─────────────────────────────────────────────────────────────────────
class FigmaHeroCard extends StatelessWidget {
  const FigmaHeroCard({
    required this.title,
    required this.body,
    this.imageAsset,
    this.imageNetwork,
    this.actionLabel,
    this.onAction,
    this.tags,
    super.key,
  });

  final String title;
  final String body;
  final String? imageAsset;
  final String? imageNetwork;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<String>? tags;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: AppDecorations.greenCardSubtle,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.heroTitle.copyWith(
                color: Colors.white,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
                height: 1.7,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            if (tags != null && tags!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: tags!
                    .map(
                      (t) => Text(
                        t,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMutedDark,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: GestureDetector(
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      actionLabel!,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// زر الشريط الذهبي (مثل «المسابقات الجارية») — إجراء مميّز بتدرّج ذهبي
// ─────────────────────────────────────────────────────────────────────
class FigmaGoldRibbonButton extends StatelessWidget {
  const FigmaGoldRibbonButton({
    required this.title,
    required this.subtitle,
    this.icon,
    this.onTap,
    this.endLabel,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? endLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppDecorations.goldRibbon,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (endLabel != null) ...[
              const SizedBox(width: 8),
              Text(
                endLabel!,
                style: AppTextStyles.titleSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// بطاقة معلومات مزدوجة، مقسومة أفقياً (مثل «15 رمضان» + «القرآن الكريم»)
// ─────────────────────────────────────────────────────────────────────
class FigmaDualCard extends StatelessWidget {
  const FigmaDualCard({
    required this.left,
    required this.right,
    this.middle,
    this.gap = 12,
    super.key,
  });

  final Widget left;
  final Widget right;
  // زخرفة اختيارية بين البطاقتين (شريط نقاط مثلاً).
  final Widget? middle;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: left),
            if (middle != null) ...[
              SizedBox(width: gap / 2),
              middle!,
              SizedBox(width: gap / 2),
            ] else
              SizedBox(width: gap),
            Expanded(child: right),
          ],
        ),
      ),
    );
  }
}

class FigmaInfoCard extends StatelessWidget {
  const FigmaInfoCard({
    required this.title,
    required this.subtitle,
    this.leadingIcon,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.titleColor,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData? leadingIcon;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  size: 18,
                  color: AppColors.accentGold,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: titleColor ?? AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
                height: 1.6,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.creamLight,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: AppColors.borderLight.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (actionIcon != null) ...[
                      Icon(actionIcon, size: 14,
                          color: AppColors.textSecondaryLight),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      actionLabel!,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// عنوان قسم صغير فوق كتلة محتوى
// ─────────────────────────────────────────────────────────────────────
class FigmaSectionTitle extends StatelessWidget {
  const FigmaSectionTitle({
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 8),
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.greenDeep,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// حقل البحث (حبّة مستديرة بأيقونة بحث بالبداية)
// ─────────────────────────────────────────────────────────────────────
class FigmaSearchField extends StatelessWidget {
  const FigmaSearchField({
    required this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.trailing,
    super.key,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        height: 42,
        decoration: AppDecorations.searchField,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 18,
              color: AppColors.textMutedLight,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                onTap: onTap,
                readOnly: readOnly,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMutedLight,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// بطاقة شهيد أو شخصية (صورة + اسم + تواريخ)
// ─────────────────────────────────────────────────────────────────────
class FigmaPersonalityCard extends StatelessWidget {
  const FigmaPersonalityCard({
    required this.label,
    required this.name,
    this.photoAsset,
    this.photoNetwork,
    this.gregorianDate,
    this.hijriDate,
    this.dateLabel,
    this.onTap,
    super.key,
  });

  final String label;
  final String name;
  final String? photoAsset;
  final String? photoNetwork;
  final String? gregorianDate;
  final String? hijriDate;
  final String? dateLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoAsset != null || photoNetwork != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: AppDecorations.card,
        child: Row(
          children: [
            if (hasPhoto)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 96,
                  child: photoAsset != null
                      ? Image.asset(photoAsset!, fit: BoxFit.cover)
                      : Image.network(photoNetwork!, fit: BoxFit.cover),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (gregorianDate != null || hijriDate != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dateLabel != null)
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8),
                            child: Text(
                              dateLabel!,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (gregorianDate != null)
                              Text(
                                gregorianDate!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            if (hijriDate != null)
                              Text(
                                hijriDate!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// شريط التنقّل السفلي (داكن بمربّعات ذهبية مستديرة)
// ─────────────────────────────────────────────────────────────────────
/// شريط تنقّل سفلي يُسحب. فيغما 269:4287.
///
/// بحالته الأولى يعرض أربعة عناصر أساسية ومقبض سحب صغير (خط «Vector 1» أعلى
/// الإطار 9 بفيغما). سحب المقبض للأعلى — أو الضغط عليه — يكشف الصف الثاني،
/// فتكتمل شبكة 4×2 مثل ما هي بملف التصميم.
///
/// • الصف الأول: المكتبة | تراث الإمام | الوسائط | الخدمات
/// • الصف الثاني: القرآن | البوصلة | حول التطبيق | حول المؤسسة
class FigmaBottomNav extends StatefulWidget {
  const FigmaBottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<FigmaNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<FigmaBottomNav> createState() => _FigmaBottomNavState();
}

class _FigmaBottomNavState extends State<FigmaBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _expanded = false;
  double _dragAccum = 0;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // dy سالب = الإصبع صعد ← إيماءة فتح.
    _dragAccum += -details.delta.dy;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldExpand = _dragAccum > 18 || velocity < -180;
    final shouldCollapse = _dragAccum < -18 || velocity > 180;
    if (shouldExpand && !_expanded) {
      _toggle();
    } else if (shouldCollapse && _expanded) {
      _toggle();
    }
    _dragAccum = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDual = widget.items.length >= 5;
    final primary = isDual ? widget.items.sublist(0, 4) : widget.items;
    final secondary =
        isDual ? widget.items.sublist(4) : const <FigmaNavItem>[];
    // نقسّم الثانوية صفوفاً بأربعة عناصر كحدّ أقصى — بفيغما الصف الثاني أربعة
    // والثالث ما فاض (عنصر واحد عادةً).
    final secondaryRows = <List<int>>[];
    for (var i = 0; i < secondary.length; i += 4) {
      final end = (i + 4) > secondary.length ? secondary.length : i + 4;
      secondaryRows.add(List<int>.generate(end - i, (k) => i + k));
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: secondary.isEmpty ? null : _onVerticalDragUpdate,
      onVerticalDragEnd: secondary.isEmpty ? null : _onVerticalDragEnd,
      child: Container(
        decoration: AppDecorations.bottomNavBar,
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // المقبض: خط ذهبي حسب فيغما. ما نعرضه إلا إذا كان بيه صف ثانوي
              // يستحق الكشف — وإلا يوعد المستخدم بشي ما موجود.
              if (secondary.isNotEmpty)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggle,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 6),
                    child: Container(
                      width: 48,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.dockHandle.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 6),
              // الصف الأساسي — ظاهر دائماً.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List<Widget>.generate(primary.length, (i) {
                  return _NavBarItem(
                    item: primary[i],
                    selected: i == widget.selectedIndex,
                    onTap: () => widget.onSelected(i),
                  );
                }),
              ),
              // الصفوف الثانوية بارتفاع متحرّك؛ الفائض ينزل لصف تحته.
              SizeTransition(
                sizeFactor: _controller,
                axisAlignment: -1,
                // ارتفاع ذاتي لا SizedBox ثابت: أي تغيير بمقاس المربّع بلا
                // ذلك يطفح خارج المساحة المحجوزة.
                child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final row in secondaryRows) ...[
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              for (final secIdx in row)
                                _NavBarItem(
                                  item: secondary[secIdx],
                                  selected: (secIdx + 4) ==
                                      widget.selectedIndex,
                                  onTap: () =>
                                      widget.onSelected(secIdx + 4),
                                  compact: true,
                                ),
                              // نحشو الصف الناقص حتى ما يتمدّد المربّع الوحيد
                              // على عرض الشاشة كله.
                              for (var pad = row.length; pad < 4; pad++)
                                const Spacer(),
                            ],
                          ),
                          if (row != secondaryRows.last)
                            const SizedBox(height: 4),
                        ],
                      ],
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

class FigmaNavItem {
  const FigmaNavItem({
    required this.label,
    this.icon,
    this.svgAsset,
    this.pngAsset,
  }) : assert(icon != null || svgAsset != null || pngAsset != null,
            'Provide an icon, svgAsset, or pngAsset');

  final String label;
  final IconData? icon;
  final String? svgAsset;
  final String? pngAsset;
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final FigmaNavItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // بقائمة فيغما (386:10137) كل المربّعات بنفس المقاس داخل شبكة أربعة
    // أعمدة (72×72، تدرّج ذهبي) — الصفوف الثانوية ما تصغر. فالأساسي والثانوي
    // يتقاسمان مقاساً واحداً.
    // ومقاس فيغما 72×72 برموز ~38 بكسل؛ شريطنا يحشر خمسة تبويبات، فننزل
    // لمربّع 60 برمز 36: أكبر مما كان وأضيق تباعداً.
    const iconBoxW = 60.0;
    const iconBoxH = 60.0;
    const iconPad = 10.0;
    const iconSize = 36.0;
    const labelSize = 11.0;
    const iconRadius = 16.0;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: iconBoxW,
                height: iconBoxH,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.dockTileActiveGlow,
                      AppColors.dockTile,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(iconRadius),
                  border: Border.all(
                    color: AppColors.dockTileBorder.withValues(
                      alpha: selected ? 1.0 : 0.55,
                    ),
                    width: selected ? 1.2 : 0.8,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.dockTileActiveGlow
                                .withValues(alpha: 0.45),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: item.pngAsset != null
                    ? Padding(
                        padding: EdgeInsets.all(iconPad),
                        child: Image.asset(
                          item.pngAsset!,
                          color: AppColors.dockTileGlyph,
                          colorBlendMode: BlendMode.srcIn,
                          fit: BoxFit.contain,
                        ),
                      )
                    : item.svgAsset != null
                        ? Padding(
                            padding: EdgeInsets.all(iconPad),
                            child: SvgPicture.asset(
                              item.svgAsset!,
                              colorFilter: const ColorFilter.mode(
                                AppColors.dockTileGlyph,
                                BlendMode.srcIn,
                              ),
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(
                            item.icon,
                            color: AppColors.dockTileGlyph,
                            size: iconSize,
                          ),
              ),
              SizedBox(height: compact ? 4 : 6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: AppTextStyles.navLabel.copyWith(
                  color: Colors.white.withValues(
                    alpha: selected ? 1.0 : 0.85,
                  ),
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: labelSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
