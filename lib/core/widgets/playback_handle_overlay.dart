// مقبض لوحة المشغّل على مستوى التطبيق.
//
// الملاحظة 22 تشترط أن تكون لوحة المشغّل «متاحة من أي شاشة ما دام المشغّل يعمل،
// لا من شاشة بعينها». نقاط الـnotch تعيش داخل [HomeHeader]، وهذا الشريط غير
// موجود في شاشات كثيرة (المسابقات، قراءة الزيارة، قارئ الـPDF، عارض الصور،
// مشغّلات الفيديو…). فنضع هنا مقبضاً ثانياً يلفّ كل شاشة.
//
// موضعه أسفل الوسط لا أعلاه: المقبض العلوي كان يزدوج مع الـnotch على الشاشات
// التي فيها شريط، وتمييز «هل الشريط ظاهر الآن؟» غير موثوق مع الـNavigator
// المتداخل في القشرة (الشاشة المغطّاة تبقى مركّبة). الأسفل لا يتعارض مع شيء،
// وهو الموضع المتعارف عليه لمشغّل مصغّر.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:anwarsajadia/core/router/app_router.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/audio_player_controller.dart';
import 'package:anwarsajadia/features/multimedia/presentation/widgets/playback_sheet.dart';

class PlaybackHandleOverlay extends ConsumerWidget {
  const PlaybackHandleOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(audioPlayerControllerProvider);

    // المزوّد كائن ثابت لا يُخطر بتغيّر قائمته، فنقرأ الحالة من بثّ المشغّل
    // نفسه: أي شيء غير `idle` يعني أن هناك مقطعاً محمَّلاً.
    return StreamBuilder<ProcessingState>(
      stream: controller.player.processingStateStream,
      builder: (context, snap) {
        final hasTrack =
            (snap.data ?? ProcessingState.idle) != ProcessingState.idle;
        return Stack(
          children: [
            child,
            if (hasTrack)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          // سياق هذا الغلاف فوق الملّاح، فنمرّر سياق
                          // الملّاح الجذري وإلا رمى showGeneralDialog.
                          onTap: () {
                            final ctx = rootNavigatorKey.currentContext;
                            if (ctx != null) showPlaybackSheet(ctx);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.cardDarkHome.withValues(
                                alpha: 0.9,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.graphic_eq_rounded,
                                  size: 15,
                                  color: AppColors.accentGold,
                                ),
                                const SizedBox(width: 8),
                                for (var i = 0; i < 7; i++) ...[
                                  if (i > 0) const SizedBox(width: 3),
                                  Container(
                                    width: 2.4,
                                    height: 2.4,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentGold,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
