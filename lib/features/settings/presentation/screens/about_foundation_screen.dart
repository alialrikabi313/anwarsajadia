// شاشة «حول المؤسسة».

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';

/// تعريف بالمؤسسة الناشرة ورسالتها وطرق التواصل معها.
class AboutFoundationScreen extends StatelessWidget {
  const AboutFoundationScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          // حبّتا تبويب: الحالي يأخذ الزيتوني الأغمق والآخر الأفتح.
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.readingSand,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'حول المؤسسة',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        context.pushReplacementNamed(RouteNames.aboutApp),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.parchment,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'حول التطبيق',
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
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                // بطاقة الشعار — نفس تصميم «حول التطبيق»: بطاقة بيضاء بالرمز
                // بلا اسم ولا عنوان إنجليزي.
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.borderLight.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Column(
                    children: [
                      SizedBox(height: 6),
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
                _Section(
                  title: 'عن المؤسسة',
                  body: 'انطلاقاً من العمق الديني والعلمي والاجتماعي لأهل بيت النبوة وأنوار الهداية الإلهية (عليهم السلام جميعاً) ، وسعياً الى تعريف المجتمع الإنساني بمآثر العترة الطاهرة لنبي الرحمة (صلى الله عليه وعليهم أجمعين) ، وإظهاراً لمظلومية الأئمة الطاهرين وخصوصا أئمة البقيع (عليهم السلام)، وما مورس في حقهم من إجحاف وتنكر وتغييب والحال أنهم أهل المدينة وسادتها وهم ورثة جدهم النبي الاكرم نسباً وعلماً ومكانةً وسؤدداً فلقد اهتم المؤمنون-جزاهم الله خيراً-قديماً وحديثاً بمحاولات كثيرة لنشر فكر أئمة البقيع وفقههم والعمل على الفات الانظار الى سمو مرتبتهم (عليهم السلام) وجلالة قدرهم في الإسلام فجزى الله العاملين كل خير.\n'
                      'ولكن لا شك أن هناك ما لابد من تسليط الضوء عليه استجابة لمتطلبات ما يعيشه المجتمع الإسلامي من فقدان للهوية وارباكٍ فكري وتأزم أخلاقي وتفككٍ إجتماعي مما دعا الى إيجاد خطاب متوازنٍ وإبرازٍ هادفٍ للحقيقةِ التي يحاول الطغاة التعمية عليها وتزييفها وشحن النفوس والعقول بالأباطيل والشبهات والأكاذيب.\n'
                      'ومن خلال تلك الجهود المشكورة للعاملين في الساحة العلمية والفكرية والثقافية، وتجسيداً لتوجيهات ونصائح المرجع الأعلى للطائفة الشيعية سماحة آية الله العظمى السيد علي الحسيني السيستاني (دام ظله الوارف) والتي ركز فيها سماحته على الاستفادة من الصحيفة السجادية بالإضافة الى القرآن الكريم ونهج البلاغة حيث قال سماحته:\n'
                      'وينبغي للمرء أن يأنس بكتب ثلاثة يتزود منها بالتأمّل والتفكير : القرآن الكريم... ونهج البلاغة... والصحيفة السجادية؛ فإنها تتضمّن أدعيةً بليغة تستمد مَضامينَها من القرآنِ الكريمِ وفيها تعليم لما ينبغي أن يكون عليه الإنسان من توجهات وهواجس ورؤى وطموح، وبيان لكيفية محاسبته لنفسه ونقده لها ومكاشفتها بخباياها وأسرارها ، ولا سيما دعاء مكارم الأخلاق منها .\n'
                      'انبثقت فكرة تأسيس مؤسسة تعنى بتراث الامام السجاد (عليه السلام) بحثاً ودراسةً وتحقيقاً وممارسةً ميدانيةً طلباً لترسيخ علمِ وفكرِ وثقافةِ أهلِ البيتِ (عليهم جميعا سلام الله) في مجتمعاتنا المتعطشة لأخذ الحقيقة الناصعة من منابعها الصافية.\n'
                      'ومن أولئك الذين يسعون دائما - باذلين الوسع بحسب الإمكانات المتاحة - لنصرة المذهب الحق وإعلاء الراية الأحق سماحة المتولي الشرعي للعتبة الحسينية المقدسة جناب الشيخ عبد المهدي الكربلائي (دامت بركاته) الذي كانت له فضيلة المبادرة لتأسيس هذه المؤسسة المباركة، حيث التقى طلبه الكريم مع همٍ طالما حملناه في قلوبنا وعقولنا لإحياء تراث الامام السجاد (عليه السلام).\n'
                      'فنسأل الحق تعالى أن يوفق الجميع لخدمة دين رب العالمين وشريعة سيد المرسلين والسادة النجباء من آل طه ويس عليهم صلوات المصلين وتسليم المسلمين، وآخر دعوانا أن الحمد لله رب العالمين.\n'
                      'رؤية المؤسسة: الريادة والتميز في إيصال علوم الامام السجاد (عليه السلام) إلى الباحثين والنخب والتعريف به وبأصحابه وبعلماء المدينة المنورة وأدوارهم في نصرة الحق والحقيقة .\n'
                      'رسالة المؤسسة\n'
                      'تحفيز الباحثين والمحققين لإثراء الجانب العلمي والفكري والثقافي المرتبط بالإمام السجاد (عليه السلام) وإشاعة روح التخلق بأخلاقه والالتزام بمبادئه بين أبنائنا في المؤسسات العلمية والنخبوية عبر أعمال وفعاليات علمية وفنية.\n'
                      'الهدف من عمل المؤسسة\n'
                      '١- تسليط الضوء على ما لم يظهر من آثار الإمام السجاد(عليه السلام ).\n'
                      '٢- بلورة صياغة جديدة وطرح رؤية فكرية شاملة فيما قد مضى العمل عليه مسبقا تتناسب ورؤية المؤسسة.\n'
                      '٣- جعلُ فكر الإمام السجاد(عليه السلام) حاضراً في الأوساط العلمية والنخبوية .\n'
                      'محاور عمل المؤسسة\n'
                      'حياة الامام زين العابدين (عليه السلام ) وتراثه الروائي والقرآني والعقائدي تحقيقا وتأليفاً.\n'
                      'الاهتمام البالغ بالصحيفة السجادية ورسالة الحقوق-على وجه الخصوص-وكل إثره(عليه السلام) بحثاً ودراسةً وتفعيلها اجتماعياً وأكاديمياً.\n'
                      'حياة أصحابهم الميامين ودورهم في حفظ الهوية الدينية.\n'
                      'واقع المدينة المنورة كونها منطلقاً للنواة الأولى للتشيع ومهدَ الفكر الإسلامي الأصيل .\n'
                      'حياة علماء الشيعة في المدينة المنورة وما جاورها.\n'
                      'فهرَس مؤلفات الشيعة في تلك الديار.\n'
                      'فهرَس المخطوطات والعمل على تحقيقها وطبعها.\n'
                      'إصدار مجلة تراثية علمية متخصصة تتناول المحاور السابقة.\n'
                      'إنشاء مكتبة تخصصية في الإمام السجاد (عليه السلام ) .\n'
                      'الجهات المستهدفة\n'
                      'طلبة العلوم الدينية.\n'
                      'الباحثون والمتخصصون من الأكاديميين.\n'
                      'الباحثون عن المعرفة.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.accentGoldDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
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
      ),
    );
  }
}
