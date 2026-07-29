// شاشة «حول التطبيق».

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';
import 'package:anwarsajadia/core/utils/helpers/share_helper.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';

/// شكر وتعريف بالأقسام وروابط المشاركة والتواصل.
class AboutAppScreen extends ConsumerWidget {
  const AboutAppScreen({super.key});

  static const _appName = 'أنوار السجادية';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          const HomeHeader(dark: true),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.primary),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const SizedBox(height: 8),
          // حبّتا تبويب (183×50، نصف قطر 15): التبويب الحالي يأخذ الزيتوني
          // الأغمق والآخر الأفتح.
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        context.pushReplacementNamed(RouteNames.aboutFoundation),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.parchment,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'حول المؤسسة',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.readingSand,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'حول التطبيق',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // بطاقة الشعار تبقى بيضاء؛ الكريمي للبطاقات النصّية تحتها.
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderLight.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    children: const [
                      SizedBox(height: 6),
                      // الشعار بلا العنوان الإنجليزي — الرمز والاسم العربي فقط.
                      Image(
                        image: AssetImage(
                          'assets/figma_assets/about_logo_noeng.png',
                        ),
                        width: 150,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.info_outline_rounded,
                  title: 'تعريف بالتطبيق',
                  body: 'بسم الله الرحمن الرحيم\n'
                      'روي عن النبي الأعظم(صلى الله عليه وآله وسلم) أنه قال: إذا كان يوم القيامة ينادي مناد أين زين العابدين؟ فكأني أنظر إلى ولدي علي بن الحسين بن علي بن أبي طالب يخطو بين الصفوف.\n'
                      'انطلاقاً من الشخصية الإلهية للإمام زين العابدين(عليه السلام) ومما تركه من تراث أصيل وبتعاون مع مؤسسة الإمام زين العابدين(عليه السلام) التابعة للعتبة الحسينية المقدسة جاء هذا التطبيق ليكون الموسوعة الأولى في مجاله، حيث شمل جميع الجوانب المرتبطة بالسيرة العطرة لسيد الساجدين(عليه السلام).\n'
                      'كما أضفنا وباقتراح من المؤسسة الكريمة بعض الأمور الجانبية .. وهي كالتالي:\n'
                      '١- نص القرآن الكريم مع شرح بسيط لبعض الكلمات الغامضة لكي يكون سبباً للتواصل المستمر مع ربيع القلوب.\n'
                      '٢ - سيرة شهداء الفتوى المباركة من الحوزة العلمية وتظهر متزامنة مع تاريخ استشهادهم وفق التاريخ الهجري.\n'
                      '٣ - توشح كل يوم من أيام السنة بمقولة خالدة للإمام زين العابدين(عليه السلام) تظهر على الشاشة الرئيسية للتطبيق.\n'
                      '٤ - تتميماً للفائدة أضفنا المناسبات المهمة للسنة، وتظهر متزامنة مع تاريخ اليوم في أعلى الشاشة الرئيسية.\n'
                      '٥- التاريخ الهجري الظاهر في أعلى الشاشة الرئيسية متزامن مع الثبوت الشرعي ويحدث بشكل تلقائي.',
                ),
                const SizedBox(height: 10),
                _LinkTile(
                  icon: Icons.share_rounded,
                  label: 'شارك التطبيق',
                  onTap: () => ShareHelper.shareText(
                    'تطبيق $_appName — تراث الإمام زين العابدين عليه السلام',
                    title: _appName,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '© ${DateTime.now().year} مؤسسة الإمام زين العابدين (ع) للبحوث والدراسات',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: AppColors.accentGoldDark, size: 22),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimaryLight,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderLight.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textMutedLight,
                ),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, color: AppColors.greenDeep, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
