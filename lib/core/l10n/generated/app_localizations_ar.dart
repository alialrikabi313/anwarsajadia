// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أنوار السجادية';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get tabQuran => 'القرآن الكريم';

  @override
  String get tabSajjad => 'الإمام السجّاد';

  @override
  String get tabMedia => 'الوسائط';

  @override
  String get tabMore => 'المزيد';

  @override
  String get homeGreetingMorning => 'صباح الخير';

  @override
  String get homeGreetingAfternoon => 'مساء الخير';

  @override
  String get homeGreetingEvening => 'مساء النور';

  @override
  String get homeQuickAccess => 'الوصول السريع';

  @override
  String get homeDailyVerse => 'آية اليوم';

  @override
  String get homeDailyDua => 'دعاء اليوم';

  @override
  String get homeContinueReading => 'متابعة القراءة';

  @override
  String get quranSurahList => 'قائمة السور';

  @override
  String get quranSearch => 'البحث في القرآن';

  @override
  String get quranSearchHint => 'ابحث بالكلمات المفتاحية...';

  @override
  String get quranMeccan => 'مكية';

  @override
  String get quranMedinan => 'مدنية';

  @override
  String get quranAyah => 'آية';

  @override
  String quranAyahCount(int count) {
    return '$count آية';
  }

  @override
  String get quranJuz => 'الجزء';

  @override
  String get quranPage => 'الصفحة';

  @override
  String get quranBookmark => 'إضافة للمفضلة';

  @override
  String get quranBookmarkRemove => 'إزالة من المفضلة';

  @override
  String get quranCopyAyah => 'نسخ الآية';

  @override
  String get quranShareAyah => 'مشاركة الآية';

  @override
  String get quranSelectReciter => 'اختيار القارئ';

  @override
  String get quranNoResults => 'لا توجد نتائج';

  @override
  String get sajjadTitle => 'الإمام السجّاد (عليه السلام)';

  @override
  String get sajjadBiography => 'سيرة الإمام';

  @override
  String get sajjadSahifa => 'الصحيفة السجادية';

  @override
  String get sajjadSahifaExplained => 'شرح الصحيفة';

  @override
  String get sajjadRisalat => 'رسالة الحقوق';

  @override
  String get sajjadMusnad => 'مسند الإمام';

  @override
  String get sajjadZiyarat => 'الزيارات';

  @override
  String get sajjadMaqamat => 'مقامات الإمام';

  @override
  String get sajjadLibrary => 'المكتبة';

  @override
  String get sajjadChapters => 'الفصول';

  @override
  String get sajjadDua => 'الدعاء';

  @override
  String get mediaTitle => 'مكتبة الوسائط';

  @override
  String get mediaVideos => 'مكتبة الفيديو';

  @override
  String get mediaAudios => 'مكتبة الصوت';

  @override
  String get mediaPhotos => 'معرض الصور';

  @override
  String get mediaLectures => 'محاضرات';

  @override
  String get mediaDocumentaries => 'وثائقيات';

  @override
  String get mediaDuas => 'أدعية';

  @override
  String get mediaNoItems => 'لا توجد عناصر';

  @override
  String get toolsTitle => 'الخدمات والأدوات';

  @override
  String get toolsQibla => 'اتجاه القبلة';

  @override
  String get toolsQuiz => 'المسابقات';

  @override
  String get toolsQuizDaily => 'مسابقة يومية';

  @override
  String get toolsQuizWeekly => 'مسابقة أسبوعية';

  @override
  String get toolsContact => 'اتصل بنا';

  @override
  String get toolsContactName => 'الاسم';

  @override
  String get toolsContactEmail => 'البريد الإلكتروني';

  @override
  String get toolsContactSubject => 'الموضوع';

  @override
  String get toolsContactMessage => 'الرسالة';

  @override
  String get toolsContactSend => 'إرسال';

  @override
  String get toolsContactSuccess => 'تم إرسال رسالتك بنجاح';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeLight => 'نهاري';

  @override
  String get settingsThemeDark => 'ليلي';

  @override
  String get settingsThemeSystem => 'تلقائي';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsNotificationsEnable => 'تفعيل الإشعارات';

  @override
  String get settingsDateConverter => 'محول التاريخ';

  @override
  String get settingsDateHijri => 'هجري';

  @override
  String get settingsDateGregorian => 'ميلادي';

  @override
  String get settingsFontSize => 'حجم الخط';

  @override
  String get settingsFontFamily => 'نوع الخط';

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String get readingFontIncrease => 'تكبير الخط';

  @override
  String get readingFontDecrease => 'تصغير الخط';

  @override
  String get readingCopy => 'نسخ';

  @override
  String get readingShare => 'مشاركة';

  @override
  String get readingBookmark => 'المفضلة';

  @override
  String get readingDiacritics => 'التشكيل';

  @override
  String get readingCopied => 'تم النسخ';

  @override
  String get errorGeneral => 'حدث خطأ غير متوقع';

  @override
  String get errorNetwork => 'لا يوجد اتصال بالإنترنت';

  @override
  String get errorCache => 'خطأ في البيانات المحلية';

  @override
  String get errorNotFound => 'لم يتم العثور على البيانات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'موافق';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get search => 'بحث';

  @override
  String get foundationActivities => 'نشاطات المؤسسة';

  @override
  String get foundationNews => 'أخبار المؤسسة';
}
