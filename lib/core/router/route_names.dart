// أسماء ومسارات المسارات. مركزة هنا حتى ما ينكتب اسم مسار نصاً بالشاشات — خطأ
// حرف واحد بالاسم ما يبيّن إلا وقت التشغيل.

/// أسماء المسارات المسمّاة (goNamed/pushNamed).
abstract final class RouteNames {
  static const String splash = 'splash';

  // جذور التبويبات الخمسة بالقشرة السفلية.
  static const String home = 'home';
  static const String quran = 'quran';
  static const String sajjad = 'sajjad';
  static const String media = 'media';
  static const String more = 'more';

  // القرآن
  static const String surahReading = 'surah-reading';
  static const String quranSearch = 'quran-search';

  // السجادية
  static const String biography = 'biography';
  static const String bookChapters = 'book-chapters';
  static const String chapterReading = 'chapter-reading';
  static const String sahifaExplained = 'sahifa-explained';
  static const String sahifaPrayerReading = 'sahifa-prayer-reading';
  static const String ziyaratList = 'ziyarat-list';
  static const String ziyaraReading = 'ziyara-reading';
  static const String maqamat = 'maqamat';
  static const String maqamDetail = 'maqam-detail';
  static const String library = 'library';
  static const String specializedLibrary = 'specialized-library';
  static const String publications = 'publications';
  static const String pdfReader = 'pdf-reader';

  // الوسائط
  static const String videoList = 'video-list';
  static const String videoPlayer = 'video-player';
  static const String videoPlaylist = 'video-playlist';
  static const String youtubePlayer = 'youtube-player';
  static const String photoViewer = 'photo-viewer';

  // الأدوات والخدمات
  static const String qibla = 'qibla';
  static const String quiz = 'quiz';
  static const String quizPlay = 'quiz-play';
  static const String quizResult = 'quiz-result';
  static const String contact = 'contact';
  static const String settings = 'settings';

  static const String bookmarks = 'bookmarks';
  static const String globalSearch = 'global-search';
  static const String audioList = 'audio-list';
  static const String audioPlayer = 'audio-player';
  static const String notifications = 'notifications';
  static const String hadithArchive = 'hadith-archive';

  // المؤسسة
  static const String activities = 'activities';
  static const String news = 'news';
  static const String occasions = 'occasions';

  static const String aboutApp = 'about-app';
  static const String aboutFoundation = 'about-foundation';

  // الشهداء
  static const String martyrs = 'martyrs';
  static const String martyrDetail = 'martyr-detail';

  // الزيارة بالإنابة
  static const String visitByProxy = 'visit-by-proxy';
}

/// المسارات النصية. ما موجود هنا غير جذور القشرة وما يُنادى بـgo() مباشرة؛
/// الباقي يوصله المسار المسمّى من [RouteNames].
abstract final class RoutePaths {
  static const String splash = '/';
  static const String home = '/home';
  static const String quran = '/quran';
  static const String sajjad = '/sajjad';
  static const String media = '/media';
  static const String more = '/more';
  static const String library = '/library';
}
