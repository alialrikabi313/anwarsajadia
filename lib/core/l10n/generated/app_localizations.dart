import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// No description provided for @appTitle.
  ///
  /// In ar, this message translates to:
  /// **'أنوار السجادية'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get tabHome;

  /// No description provided for @tabQuran.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get tabQuran;

  /// No description provided for @tabSajjad.
  ///
  /// In ar, this message translates to:
  /// **'الإمام السجّاد'**
  String get tabSajjad;

  /// No description provided for @tabMedia.
  ///
  /// In ar, this message translates to:
  /// **'الوسائط'**
  String get tabMedia;

  /// No description provided for @tabMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get tabMore;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء النور'**
  String get homeGreetingEvening;

  /// No description provided for @homeQuickAccess.
  ///
  /// In ar, this message translates to:
  /// **'الوصول السريع'**
  String get homeQuickAccess;

  /// No description provided for @homeDailyVerse.
  ///
  /// In ar, this message translates to:
  /// **'آية اليوم'**
  String get homeDailyVerse;

  /// No description provided for @homeDailyDua.
  ///
  /// In ar, this message translates to:
  /// **'دعاء اليوم'**
  String get homeDailyDua;

  /// No description provided for @homeContinueReading.
  ///
  /// In ar, this message translates to:
  /// **'متابعة القراءة'**
  String get homeContinueReading;

  /// No description provided for @quranSurahList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة السور'**
  String get quranSurahList;

  /// No description provided for @quranSearch.
  ///
  /// In ar, this message translates to:
  /// **'البحث في القرآن'**
  String get quranSearch;

  /// No description provided for @quranSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث بالكلمات المفتاحية...'**
  String get quranSearchHint;

  /// No description provided for @quranMeccan.
  ///
  /// In ar, this message translates to:
  /// **'مكية'**
  String get quranMeccan;

  /// No description provided for @quranMedinan.
  ///
  /// In ar, this message translates to:
  /// **'مدنية'**
  String get quranMedinan;

  /// No description provided for @quranAyah.
  ///
  /// In ar, this message translates to:
  /// **'آية'**
  String get quranAyah;

  /// No description provided for @quranAyahCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} آية'**
  String quranAyahCount(int count);

  /// No description provided for @quranJuz.
  ///
  /// In ar, this message translates to:
  /// **'الجزء'**
  String get quranJuz;

  /// No description provided for @quranPage.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة'**
  String get quranPage;

  /// No description provided for @quranBookmark.
  ///
  /// In ar, this message translates to:
  /// **'إضافة للمفضلة'**
  String get quranBookmark;

  /// No description provided for @quranBookmarkRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المفضلة'**
  String get quranBookmarkRemove;

  /// No description provided for @quranCopyAyah.
  ///
  /// In ar, this message translates to:
  /// **'نسخ الآية'**
  String get quranCopyAyah;

  /// No description provided for @quranShareAyah.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الآية'**
  String get quranShareAyah;

  /// No description provided for @quranSelectReciter.
  ///
  /// In ar, this message translates to:
  /// **'اختيار القارئ'**
  String get quranSelectReciter;

  /// No description provided for @quranNoResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get quranNoResults;

  /// No description provided for @sajjadTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإمام السجّاد (عليه السلام)'**
  String get sajjadTitle;

  /// No description provided for @sajjadBiography.
  ///
  /// In ar, this message translates to:
  /// **'سيرة الإمام'**
  String get sajjadBiography;

  /// No description provided for @sajjadSahifa.
  ///
  /// In ar, this message translates to:
  /// **'الصحيفة السجادية'**
  String get sajjadSahifa;

  /// No description provided for @sajjadSahifaExplained.
  ///
  /// In ar, this message translates to:
  /// **'شرح الصحيفة'**
  String get sajjadSahifaExplained;

  /// No description provided for @sajjadRisalat.
  ///
  /// In ar, this message translates to:
  /// **'رسالة الحقوق'**
  String get sajjadRisalat;

  /// No description provided for @sajjadMusnad.
  ///
  /// In ar, this message translates to:
  /// **'مسند الإمام'**
  String get sajjadMusnad;

  /// No description provided for @sajjadZiyarat.
  ///
  /// In ar, this message translates to:
  /// **'الزيارات'**
  String get sajjadZiyarat;

  /// No description provided for @sajjadMaqamat.
  ///
  /// In ar, this message translates to:
  /// **'مقامات الإمام'**
  String get sajjadMaqamat;

  /// No description provided for @sajjadLibrary.
  ///
  /// In ar, this message translates to:
  /// **'المكتبة'**
  String get sajjadLibrary;

  /// No description provided for @sajjadChapters.
  ///
  /// In ar, this message translates to:
  /// **'الفصول'**
  String get sajjadChapters;

  /// No description provided for @sajjadDua.
  ///
  /// In ar, this message translates to:
  /// **'الدعاء'**
  String get sajjadDua;

  /// No description provided for @mediaTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكتبة الوسائط'**
  String get mediaTitle;

  /// No description provided for @mediaVideos.
  ///
  /// In ar, this message translates to:
  /// **'مكتبة الفيديو'**
  String get mediaVideos;

  /// No description provided for @mediaAudios.
  ///
  /// In ar, this message translates to:
  /// **'مكتبة الصوت'**
  String get mediaAudios;

  /// No description provided for @mediaPhotos.
  ///
  /// In ar, this message translates to:
  /// **'معرض الصور'**
  String get mediaPhotos;

  /// No description provided for @mediaLectures.
  ///
  /// In ar, this message translates to:
  /// **'محاضرات'**
  String get mediaLectures;

  /// No description provided for @mediaDocumentaries.
  ///
  /// In ar, this message translates to:
  /// **'وثائقيات'**
  String get mediaDocumentaries;

  /// No description provided for @mediaDuas.
  ///
  /// In ar, this message translates to:
  /// **'أدعية'**
  String get mediaDuas;

  /// No description provided for @mediaNoItems.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر'**
  String get mediaNoItems;

  /// No description provided for @toolsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات والأدوات'**
  String get toolsTitle;

  /// No description provided for @toolsQibla.
  ///
  /// In ar, this message translates to:
  /// **'اتجاه القبلة'**
  String get toolsQibla;

  /// No description provided for @toolsQuiz.
  ///
  /// In ar, this message translates to:
  /// **'المسابقات'**
  String get toolsQuiz;

  /// No description provided for @toolsQuizDaily.
  ///
  /// In ar, this message translates to:
  /// **'مسابقة يومية'**
  String get toolsQuizDaily;

  /// No description provided for @toolsQuizWeekly.
  ///
  /// In ar, this message translates to:
  /// **'مسابقة أسبوعية'**
  String get toolsQuizWeekly;

  /// No description provided for @toolsContact.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get toolsContact;

  /// No description provided for @toolsContactName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get toolsContactName;

  /// No description provided for @toolsContactEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get toolsContactEmail;

  /// No description provided for @toolsContactSubject.
  ///
  /// In ar, this message translates to:
  /// **'الموضوع'**
  String get toolsContactSubject;

  /// No description provided for @toolsContactMessage.
  ///
  /// In ar, this message translates to:
  /// **'الرسالة'**
  String get toolsContactMessage;

  /// No description provided for @toolsContactSend.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get toolsContactSend;

  /// No description provided for @toolsContactSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رسالتك بنجاح'**
  String get toolsContactSuccess;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In ar, this message translates to:
  /// **'نهاري'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In ar, this message translates to:
  /// **'ليلي'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get settingsThemeSystem;

  /// No description provided for @settingsNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsEnable.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get settingsNotificationsEnable;

  /// No description provided for @settingsDateConverter.
  ///
  /// In ar, this message translates to:
  /// **'محول التاريخ'**
  String get settingsDateConverter;

  /// No description provided for @settingsDateHijri.
  ///
  /// In ar, this message translates to:
  /// **'هجري'**
  String get settingsDateHijri;

  /// No description provided for @settingsDateGregorian.
  ///
  /// In ar, this message translates to:
  /// **'ميلادي'**
  String get settingsDateGregorian;

  /// No description provided for @settingsFontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get settingsFontSize;

  /// No description provided for @settingsFontFamily.
  ///
  /// In ar, this message translates to:
  /// **'نوع الخط'**
  String get settingsFontFamily;

  /// No description provided for @settingsAbout.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get settingsAbout;

  /// No description provided for @readingFontIncrease.
  ///
  /// In ar, this message translates to:
  /// **'تكبير الخط'**
  String get readingFontIncrease;

  /// No description provided for @readingFontDecrease.
  ///
  /// In ar, this message translates to:
  /// **'تصغير الخط'**
  String get readingFontDecrease;

  /// No description provided for @readingCopy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get readingCopy;

  /// No description provided for @readingShare.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get readingShare;

  /// No description provided for @readingBookmark.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get readingBookmark;

  /// No description provided for @readingDiacritics.
  ///
  /// In ar, this message translates to:
  /// **'التشكيل'**
  String get readingDiacritics;

  /// No description provided for @readingCopied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get readingCopied;

  /// No description provided for @errorGeneral.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع'**
  String get errorGeneral;

  /// No description provided for @errorNetwork.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get errorNetwork;

  /// No description provided for @errorCache.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في البيانات المحلية'**
  String get errorCache;

  /// No description provided for @errorNotFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على البيانات'**
  String get errorNotFound;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get ok;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @foundationActivities.
  ///
  /// In ar, this message translates to:
  /// **'نشاطات المؤسسة'**
  String get foundationActivities;

  /// No description provided for @foundationNews.
  ///
  /// In ar, this message translates to:
  /// **'أخبار المؤسسة'**
  String get foundationNews;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
