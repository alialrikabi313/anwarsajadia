// حبّة الرأس اللي تتصدّر كل شاشة: قائمة، تاريخ هجري، نقاط ذهبية، زر صوت.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart'
    show IntArabicExtension;
import 'package:anwarsajadia/core/utils/helpers/hijri_calendar_provider.dart';
import 'package:anwarsajadia/features/multimedia/presentation/widgets/playback_sheet.dart';
import 'package:anwarsajadia/features/notifications/presentation/providers/notifications_provider.dart';

// حبّة شاشات التفصيل (الصحيفة، المكتبة، القرآن…).
const Color _kBrandCharcoal = AppColors.primary;
// حبّة الشاشة الرئيسية (فيغما «الواجهة» 386:3798).
const Color _kBrandGreen = AppColors.primaryDark;
// الزيتوني بقي خياراً اختيارياً (ما يُستعمل حالياً بعد ما انتقلت الوسائط
// للحبّة الداكنة)، ونبقيه لأن الواجهة لسّه تقبل `olive:true`.
const Color _kBrandOlive = AppColors.olive;

class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    this.onMenuTap,
    this.onAudioTap,
    this.hasNotification,
    this.dark = true,
    this.olive = false,
    this.green = false,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onAudioTap;
  // لمّا ما يكون null يتجاوز حالة «غير مقروء» المكتشَفة تلقائياً. خلّيه null
  // حتى تجي النقطة من مخزن الإشعارات نفسه.
  final bool? hasNotification;
  // نسخة فحمية داكنة لشاشات التفصيل.
  final bool dark;
  // نسخة زيتونية للوسائط، بنصّ تاريخ أغمق.
  final bool olive;
  // نسخة خضراء لحبّة الرئيسية.
  final bool green;

  static const _hijriMonths = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static const _gregorianMonths = [
    'كانون الثاني',
    'شباط',
    'آذار',
    'نيسان',
    'أيار',
    'حزيران',
    'تموز',
    'آب',
    'أيلول',
    'تشرين الأول',
    'تشرين الثاني',
    'كانون الأول',
  ];

  static const _weekdays = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  String _formatDate() {
    final now = DateTime.now();
    final hijri = hijriOf(now);

    final weekday = _weekdays[(now.weekday - 1).clamp(0, 6)];
    final gMonth = _gregorianMonths[now.month - 1];
    final gDay = now.day.toArabicNumeral();
    final hDay = hijri.day.toArabicNumeral();
    final hMonth = _hijriMonths[hijri.monthNumber - 1];
    final hYear = hijri.year.toArabicNumeral();

    return '$weekday $gDay $gMonth $hDay $hMonth، $hYear هـ';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // نعيد البناء بعد ما يوصل التاريخ الرسمي من مكتب السيد.
    ref.watch(hijriTodayProvider);
    final formatted = _formatDate();

    // بتصميم 2026 صارت الحبّة فحمية داكنة بكل الأقسام؛ والزيتوني يبقى
    // اختيارياً لشاشات الوسائط اللي تريد النبرة الأدفأ.
    final bgColor = green
        ? _kBrandGreen
        : olive
            ? _kBrandOlive
            : _kBrandCharcoal;
    // لون نص التاريخ يتبع لون الحبّة حتى يبقى التباين مقروءاً.
    final textColor =
        olive ? AppColors.primary : AppColors.cream;

    // نقطة الإشعار تجي من المخزن الحقيقي ما لم تُتجاوَز صراحةً، وما تنعرض
    // إلا إذا كان بيه إشعار غير مقروء فعلاً.
    final showDot = hasNotification ??
        ref
            .watch(notificationsProvider)
            .any((n) => !n.read);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        // فيغما 269:3668: مقاس 375×59 بنصف قطر 17.
        child: Container(
          height: 59,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(17),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          // الترتيب البصري (يسار←يمين): قائمة | تاريخ | نقاط | زر صوت.
          // ومع RTL أول عنصر يطلع باليمين، فنكتبهم يمين←يسار:
          // صوت ← نقاط ← نص ← قائمة.
          child: Row(
            children: [
              _AudioButton(
                // يفتح لوحة التشغيل العامة: الصوت يكمل شغّالاً أثناء التنقّل،
                // وهذي تتحكّم بيه من أي شاشة.
                onTap: onAudioTap ?? () => showPlaybackSheet(context),
              ),
              const SizedBox(width: 6),
              const _GoldDotRow(),
              const SizedBox(width: 4),
              Expanded(
                child: Center(
                  // فيغما 269:3672: خط Inter/13/w500.
                  child: Text(
                    formatted,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: olive ? FontWeight.w700 : FontWeight.w500,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _MenuButton(
                onTap: onMenuTap ??
                    () => context.pushNamed(RouteNames.notifications),
                hasNotification: showDot,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ثلاثة خطوط أفقية ونقطة إشعار ذهبية صغيرة بالأعلى يميناً.
class _MenuButton extends StatelessWidget {
  const _MenuButton({this.onTap, this.hasNotification = false});

  final VoidCallback? onTap;
  final bool hasNotification;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // نرسم خطوط القائمة بـCustomPaint حتى ما نتعلّق بملف SVG
              // لازم يطابق فيغما بالضبط.
              const Center(
                child: SizedBox(
                  width: 22,
                  height: 16,
                  child: CustomPaint(painter: _HamburgerPainter()),
                ),
              ),
              if (hasNotification)
                Positioned(
                  // نقطة الإشعار البرتقالية/الذهبية حسب حبّة 2026.
                  top: 2,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.headerPillNotifDot,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _kBrandCharcoal,
                        width: 1.5,
                      ),
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

class _HamburgerPainter extends CustomPainter {
  const _HamburgerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // الخط الأعلى — أقصر شوي
    canvas.drawLine(
      Offset(2, 2),
      Offset(size.width - 6, 2),
      paint,
    );
    // الأوسط — بعرض كامل
    canvas.drawLine(
      Offset(2, size.height / 2),
      Offset(size.width - 2, size.height / 2),
      paint,
    );
    // والأسفل — أقصر
    canvas.drawLine(
      Offset(2, size.height - 2),
      Offset(size.width - 10, size.height - 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HamburgerPainter oldDelegate) => false;
}

// صف أفقي صغير من سبع نقاط ذهبية، ~2 بكسل لكل وحدة.
class _GoldDotRow extends StatelessWidget {
  const _GoldDotRow();

  @override
  Widget build(BuildContext context) {
    // فيغما 269:3673: سبع دوائر 1.8×1.8 بعرض إجمالي 27.
    return SizedBox(
      width: 27,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          7,
          (i) => Container(
            width: 1.8,
            height: 1.8,
            decoration: const BoxDecoration(
              color: AppColors.sand,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

// زر دائري محدَّد بأيقونة تشغيل. فيغما 269:3681: قطر 28.4 بحدّ رقّي.
class _AudioButton extends StatelessWidget {
  const _AudioButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.headerDotGreen,
            border: Border.all(
              color: AppColors.accentGoldLight,
              width: 1.2,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/icons/play_duotone.svg',
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                AppColors.accentGoldLight,
                BlendMode.srcIn,
              ),
              placeholderBuilder: (_) => const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.accentGoldLight,
                size: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
