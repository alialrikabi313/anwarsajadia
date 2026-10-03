// لوحة ألوان التطبيق كلها. عدّل هنا فقط — ممنوع Color(0xFF...) مبثوث بالويدجتس،
// لأن أول ما يتغيّر التصميم بفيغما نصير نلاحق الرقم بخمسين شاشة.
//
// كل قيمة مسحوبة من ملف فيغما «أنوار سجادية» الصحيح، والأرقام بجنب بعض التوكنات
// هي عدد مرات ورودها بالتصدير — بيها نعرف اللون الأساس من الشاذّ.

import 'package:flutter/material.dart';

abstract final class AppColors {
  // ──────────────────────────────────────────────
  // لوحة الهوية
  // ──────────────────────────────────────────────

  // ما بالتصميم أخضر أصلاً: الأسطح واللمسات الأساسية فحمية دافئة. (الأخضر
  // اللي كان بهذي التوكنات جاء من ملف فيغما الغلط؛ `success` وحده يبقى أخضر
  // لأنه إشارة صحّة دلالية لا لون هوية.)
  static const primary = Color(0xFF333037);
  static const primaryLight = Color(0xFF46444A);
  static const primaryDark = Color(0xFF2E2A32);

  // أخضر مزرقّ غامق لحبّة رأس الرئيسية وتبويب السجادية النشط ولمسات صغيرة.
  // فيغما 269:3629 «Frame 12».
  static const tealDeep = Color(0xFF006654);

  // الذهبي — الزخارف الإسلامية والإبرازات وأزرار البطل.
  static const accentGold = Color(0xFFB8955D);
  static const accentGoldLight = Color(0xFFE0B860);
  static const accentGoldDark = Color(0xFFA79A6D);
  // ذهبي دافئ لنقطة أيقونة رأس الرئيسية وحشو خط البطل. فيغما 269:3629.
  static const goldWarm = Color(0xFFD7AE74);

  // الزيتوني — خلفية قسم المكتبة، ولون تراب دافئ.
  static const olive = Color(0xFFA79A6D);
  static const oliveLight = Color(0xFFC4BAAE);
  static const oliveDark = Color(0xFF8A7E55);

  // الكريمي والرَّق. كريمي الشاشات الحقيقي بفيغما #F2EFE8 (146×) لا #F3ECE2
  // القديم (15×)، و #F0E3D3 هو رقّ دافئ مستعمل بكثرة (364×) كقاعدة سطح القراءة.
  static const cream = Color(0xFFF2EFE8);
  static const creamLight = Color(0xFFF7F2EA);
  static const creamDark = Color(0xFFEBE7DE);
  static const warmParchment = Color(0xFFF0E3D3); // 364× قاعدة سطح القراءة
  static const parchment = Color(0xFFD9D7CB);
  static const sand = Color(0xFFD0BB9E);

  // ── توكنات الرئيسية وكل قسم (فيغما «أنوار سجادية»، الواجهة 386:3798) ──
  static const homeBg = cream; // خلفية الرئيسية
  static const homeHeaderBg = Color(0xFF2E2A32); // حبّة رأس الرئيسية، نصف قطر 20
  static const cardDarkHome = Color(0xFF333037); // بطاقات الحقوق/المسابقة/السجادية/القبلة
  static const occasionCard = Color(0xFFD5D0C3); // بطاقة المناسبة بالرئيسية
  static const readingSand = Color(0xFFD2CEB3); // بطاقة القرآن والأسطح الرملية
  static const libraryHomeBg = Color(0xFFACA078); // لوحة «اصدارات المؤسسة» الزيتونية
  static const sahifaBg = Color(0xFFA99E78); // زيتوني المكتبة/الصحيفة

  // أسطح فحمية وداكنة
  static const charcoal = Color(0xFF3F4144);
  static const charcoalDeep = Color(0xFF33363F);
  static const charcoalDarker = Color(0xFF23211F);
  static const ink = Color(0xFF222222);
  static const blackPure = Color(0xFF000000);

  // الأخضر الدلالي وشريط اللمسة
  static const success = Color(0xFF4CA870);
  static const greenDeep = Color(0xFF2E2A32);
  static const greenMuted = Color(0xFF1A1E15);

  // أزرق بلمسات محدودة
  static const slate = Color(0xFF273B4A);
  static const slateLight = Color(0xFF41485C);

  // درجات الرمادي
  static const gray100 = Color(0xFFF7F7F7);
  static const gray200 = Color(0xFFEBEBEB);
  static const gray300 = Color(0xFFD9D9D9);
  static const gray400 = Color(0xFFB9B9B9);
  static const gray500 = Color(0xFF9D9D9D);
  static const gray600 = Color(0xFF6E6E6E);
  static const gray700 = Color(0xFF555555);
  static const gray800 = Color(0xFF363636);
  static const gray900 = Color(0xFF222222);

  // ──────────────────────────────────────────────
  // السمة الفاتحة (الافتراضية) — لوحة الكريمي والرَّق
  // ──────────────────────────────────────────────
  static const backgroundLight = cream;
  static const surfaceLight = creamLight;
  static const cardLight = creamDark;
  static const cardElevatedLight = Color(0xFFF2EFE8);
  static const textPrimaryLight = Color(0xFF3F4144);
  static const textSecondaryLight = Color(0xFF6E6E6E);
  static const textMutedLight = Color(0xFF9D9D9D);
  // نص ثانوي بميلان بنفسجي دافئ — يستعمله وصف الحالة الفارغة فوق الكريمي.
  static const textSecondaryWarm = Color(0xFF555158);
  static const dividerLight = Color(0xFFD9D7CB);
  static const borderLight = Color(0xFFD0BB9E);

  // شريط التنقّل السفلي — يبقى داكناً دائماً ليتباين مع الخلفية الكريمية.
  static const navBarLight = Color(0xFF3F4144);
  static const navIconLight = Color(0xFFE0B860);
  static const navLabelLight = Color(0xFFFFFFFF);

  // ── رصيف التنقّل العائم (إعادة تصميم فيغما 2026) ─────────────────────
  // سطح داكن مقوّس من الأعلى يحمل مربّعات ذهبية لكل تبويب. توكنات إضافية —
  // navBarLight يبقى لأي موضع لسّه يستعمله.
  static const dockBg = Color(0xFF2A2A2A); // خلفية الرصيف
  static const dockHandle = Color(0xFFE0B860); // خط السحب الذهبي
  static const dockTile = Color(0xFFD4AF6A); // وجه المربّع
  static const dockTileBorder = Color(0xFFB8955D); // حافة ذهبية أغمق
  static const dockTileGlyph = Color(0xFF5D4732); // أيقونة بنّية جوّا المربّع
  static const dockTileActiveGlow = Color(0xFFE0B860); // توهّج المربّع النشط
  static const dockLabel = Color(0xFFFFFFFF); // عنوان التبويب

  // ── حبّة الرأس ──────────────────────────────────────────────────────
  // حبّة داكنة عائمة أعلى كل شاشة (تتكرر بكل تصديرات فيغما بلا استثناء).
  static const headerPillBg = Color(0xFF2A2A2A);
  static const headerPillText = Color(0xFFFFFFFF);
  static const headerPillIcon = Color(0xFFE0B860);
  static const headerPillNotifDot = Color(0xFFE0931E); // شارة الإشعار البرتقالية

  // ──────────────────────────────────────────────
  // السمة الداكنة — أخضر عميق وفحمي
  // ──────────────────────────────────────────────
  static const backgroundDark = Color(0xFF1A1E15);
  static const surfaceDark = Color(0xFF23211F);
  static const cardDark = Color(0xFF2E6E62);
  static const cardElevatedDark = Color(0xFF33363F);
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFFD9D7CB);
  static const textMutedDark = Color(0xFFB0AAAA);
  static const dividerDark = Color(0xFF3A3A3A);
  static const borderDark = Color(0xFF46444A);

  static const navBarDark = Color(0xFF23211F);
  static const navIconDark = Color(0xFFE0B860);
  static const navLabelDark = Color(0xFFFFFFFF);

  // ──────────────────────────────────────────────
  // ألوان خاصة بكل قسم
  // ──────────────────────────────────────────────

  // المكتبة — خلفية زيتونية (فيغما 276:3539).
  static const libraryBg = Color(0xFFA99E77);
  static const libraryCard = Color(0xFFEBE7DE);

  // الوسائط — داكنة دائماً (شاشات «الوسائط» بفيغما).
  static const mediaBg = Color(0xFF171718);
  static const mediaCard = Color(0xFF363636);
  static const mediaText = Color(0xFFD9D9D9);

  // ──────────────────────────────────────────────
  // ألوان الحالات الدلالية
  // ──────────────────────────────────────────────
  static const error = Color(0xFFD32F2F);
  static const warning = Color(0xFFF7B161);
  static const info = Color(0xFF273B4A);

  // إبراز مطابقة البحث داخل النتائج — أصفر دافئ يتباين مع الرَّق ولا يطمس النص.
  static const searchHighlight = Color(0xFFFFE97F);

  // ──────────────────────────────────────────────
  // خاصة بالقراءة (قرآن، أدعية، سِيَر)
  // ──────────────────────────────────────────────
  static const quranGold = Color(0xFFB8955D);
  static const ayahMarker = Color(0xFFA79A6D);
  static const sajdaHighlight = Color(0x1AB8955D);


  // ── توكنات أُضيفت لمّا جمعنا الألوان المبثوثة بالشاشات ────────────────
  // كانت مكتوبة أرقاماً بأكثر من ملف؛ جمعناها هنا حتى تتغيّر بموضع واحد.
  static const cardOliveMuted = Color(0xFFB5AE81);  // بطاقات الرئيسية الزيتونية
  static const compassInk = Color(0xFF2E2A22);      // خلفية البوصلة وعقاربها
  static const mediaSurface = Color(0xFF2A2A2E);    // أسطح شاشات الوسائط
  static const answerRight = Color(0xFF4CAF50);     // إجابة صحيحة بالمسابقة
  static const answerWrong = Color(0xFFE53935);     // إجابة خاطئة بالمسابقة
  static const inkSoft = Color(0xFF212121);         // نص أسود مخفَّف
  static const grayWarm = Color(0xFF847B7B);        // حدود وظلال دافئة
  static const sandMuted = Color(0xFFC4BAAD);       // فواصل فوق الرملي
  static const goldPale = Color(0xFFF0DA8F);        // بداية تدرّج ذهبي فاتح
  static const goldPaleWarm = Color(0xFFE1CC83);    // تدرّج ذهبي أدفأ
  static const surfaceNearBlack = Color(0xFF1E1E1E); // أغلفة الكتب والصور



  // ألوان بشفافية مضمّنة — نبقيها توكنات حتى ما تنكتب قيمة alpha يدوياً بالشاشات.
  static const dividerPrimarySoft = Color(0x55333037); // فاصل خافت فوق الرملي
  static const shadowBlack25 = Color(0x40000000);      // ظلّ شريط التنقّل
  static const dividerInkHalf = Color(0x80222222);     // فاصل داخل بطاقة الشهيد

  // ── ألوان مواضع بعينها ────────────────────────────────────────────────
  // قيم تصميم تخصّ شاشة أو عنصراً واحداً. مكانها هنا لا داخل الويدجت، حتى
  // يبقى كل لون بالتطبيق منظوراً بملف واحد.

  // البوصلة
  static const qiblaPageBg = Color(0xFFB7AC80);
  static const qiblaBackdropStart = Color(0xFFD1CA9E);
  static const qiblaBackdropEnd = Color(0xFF867F52);
  static const qiblaRowSelected = Color(0xFFDCD0B9);
  static const qiblaRowSand = Color(0xFFD9CDB6);
  static const qiblaSheetSurface = Color(0xFFF3EFE6);
  static const qiblaSheetInk = Color(0xFF5A5340);

  // زرّا بطاقة الواجهة — قيمٌ مأخوذة بالقياس من صورة التصميم المعتمدة:
  // حشوان مصمتان بلا تدرّج ولا حدّ.
  static const heroBioFill = Color(0xFFD7AF74);   // زرّ سيرة الإمام
  static const heroBioInk = Color(0xFF3F312D);
  static const heroHikamFill = Color(0xFF706844); // زرّ جميع الحِكَم
  static const heroHikamInk = Color(0xFFC7BF97);

  // المقامات والزيارات
  static const maqamCardSand = Color(0xFFE5DBC2);
  // شريط الموقع داخل بطاقة المقام: رمادي أفتح من لوح البطاقة الفحمي حتى يبرز
  // فوقه (من التصميم المعتمد لصفحتي المقامات).
  static const maqamLocationSlate = Color(0xFF4A4750);
  static const maqamCoverStart = Color(0xFF5B4A2F);
  static const maqamCoverEnd = Color(0xFF8C7340);
  static const medallionSand = Color(0xFFD9CFB4);
  static const medallionGoldStart = Color(0xFFE8D9B0);
  static const medallionGoldEnd = Color(0xFFC8AE76);
  static const medallionGoldBorder = Color(0xFF8C6F44);
  static const shrineIconBrown = Color(0xFF6B5C3D);

  // أغلفة الكتب المولَّدة
  static const bookCoverGreenStart = Color(0xFF2C3A33);
  static const bookCoverGreenEnd = Color(0xFF16211C);
  static const bookCoverGold = Color(0xFF978E57);
  static const bookCoverCream = Color(0xFFE8E2C9);
  static const bookCoverInk = Color(0xFF1D1D1D);

  // الرئيسية
  static const labelGrayHome = Color(0xFF464349);
  static const pillGrayLight = Color(0xFFEAEAEA);
  static const dotsGray = Color(0xFFC0BBB5);
  static const nearWhite = Color(0xFFFCFCFC);
  static const borderGrayLibrary = Color(0xFF5C5C5C);
  static const visitPillGreen = Color(0xFF27472E);
  static const headerDotGreen = Color(0xFF1F2412);

  // زخارف وحدود
  static const ornamentSand = Color(0xFFA89876);
  static const ornamentInk = Color(0xFF3F3725);
  static const cardBorderOlive = Color(0xFF6B6A4A);
  static const panelParchment = Color(0xFFE7E3D2);
  static const panelParchmentAlt = Color(0xFFE5E2D1);
  static const searchBorderGray = Color(0xFFA6A6A6);
  static const iconGray = Color(0xFF666666);
  static const frameGrayDark = Color(0xFF5F5A55);
  static const martyrDivider = Color(0xFF8A8467);
  static const notifGray = Color(0xFF545454);
  static const libraryInk = Color(0xFF2A2620);

  // المناسبات: شارة ولادة وشارة استشهاد
  static const badgeBirth = Color(0xFF2E6B4F);
  static const badgeMartyrdom = Color(0xFF8C2E2E);

  // القرآن
  static const quranBrownGold = Color(0xFF9E7A45);
  static const quranSheetDark = Color(0xFF222125);

  // الوسائط
  static const mediaGold = Color(0xFFC9A85C);
  static const mediaCardBlack = Color(0xFF141416);
  static const mediaRowStart = Color(0xFF524D5A);
  static const mediaRowEnd = Color(0xFF37333E);
  static const miniPlayerBg = Color(0xFF26242A);
  static const sliderGold = Color(0xFFCBBA80);
  static const sliderGoldMuted = Color(0xFFADA178);

  // المسابقة: ألوان النتيجة الفاتحة
  static const answerRightSoft = Color(0xFF81C784);
  static const answerWrongSoft = Color(0xFFEF9A9A);

  // إبراز افتراضي لويدجت النص المبرَز
  static const highlightYellow = Color(0xFFFFEB3B);

  // ──────────────────────────────────────────────
  // تدرّج شريط البطل / اللافتة الترويجية
  // ──────────────────────────────────────────────
  static const ribbonGoldStart = Color(0xFFE0B860);
  static const ribbonGoldEnd = Color(0xFFB8955D);

  // ──────────────────────────────────────────────
  // أسماء قديمة — مبقاة حتى ما ينكسر ما يستعملها
  // ──────────────────────────────────────────────
  // لمسات الهوية أُعيد ربطها باللوحة الدافئة (ما بالتصميم أخضر). `success`
  // يبقى أخضر لأنه إشارة صحّة لا لون هوية.
  static const cyan = Color(0xFF333037);
  static const cyanLight = Color(0xFF46444A);
  static const cyanDark = Color(0xFF2E2A32);
  static const green = Color(0xFF333037);
  static const brown = Color(0xFF775135);
  static const brownLight = Color(0xFF9A7054);
  static const darkGray = Color(0xFF363636);
  static const offWhite = cream;
  static const primaryGreen = Color(0xFF333037);
  static const primaryGreenLight = Color(0xFF46444A);
  static const primaryGreenDark = Color(0xFF2E2A32);
  static const toolQibla = Color(0xFFA79A6D);
  static const toolQuiz = Color(0xFFB8955D);
  static const toolMedia = Color(0xFF273B4A);
  static const toolSettings = Color(0xFF3F4144);
}
