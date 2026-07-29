// خريطة التنقّل كلها بملف واحد. القشرة StatefulShellRoute بستة فروع (تبويبات)
// يحتفظ كل واحد منها بمكدّسه، وفوقها مسارات عليا تنفتح بملء الشاشة بلا شريط
// تبويبات. أي شاشة جديدة تنضاف هنا وباسمها بـRouteNames.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/features/splash/presentation/screens/splash_screen.dart';
import 'package:anwarsajadia/features/home/presentation/screens/home_screen.dart';
import 'package:anwarsajadia/features/home/presentation/screens/home_tab_screen.dart';
import 'package:anwarsajadia/features/quran/presentation/screens/surah_list_screen.dart';
import 'package:anwarsajadia/features/quran/presentation/screens/quran_reading_screen.dart';
import 'package:anwarsajadia/features/quran/presentation/screens/quran_search_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/sajjad_home_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/biography_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/book_chapters_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/chapter_reading_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/ziyarat_list_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/ziyara_reading_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/maqamat_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/maqam_detail_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/library_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/specialized_library_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/publications_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/pdf_reader_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/sahifa_explained_screen.dart';
import 'package:anwarsajadia/features/sajjad/presentation/screens/sahifa_prayer_reading_screen.dart';
import 'package:anwarsajadia/features/multimedia/presentation/screens/multimedia_home_screen.dart';
import 'package:anwarsajadia/features/multimedia/presentation/screens/video_list_screen.dart';
import 'package:anwarsajadia/features/multimedia/presentation/screens/video_playlist_screen.dart';
import 'package:anwarsajadia/features/multimedia/presentation/screens/youtube_video_screen.dart';
import 'package:anwarsajadia/features/multimedia/presentation/screens/video_player_screen.dart';
import 'package:anwarsajadia/features/multimedia/presentation/screens/audio_list_screen.dart';
import 'package:anwarsajadia/features/multimedia/presentation/screens/audio_player_screen.dart';
import 'package:anwarsajadia/features/multimedia/presentation/screens/photo_gallery_screen.dart';
import 'package:anwarsajadia/features/martyrs/presentation/screens/martyrs_list_screen.dart';
import 'package:anwarsajadia/features/martyrs/presentation/screens/martyr_detail_screen.dart';
import 'package:anwarsajadia/features/visit_by_proxy/presentation/screens/visit_by_proxy_screen.dart';
import 'package:anwarsajadia/features/tools/presentation/screens/tools_home_screen.dart';
import 'package:anwarsajadia/features/tools/presentation/screens/qibla_screen.dart';
import 'package:anwarsajadia/features/tools/presentation/screens/quiz_list_screen.dart';
import 'package:anwarsajadia/features/tools/presentation/screens/quiz_screen.dart';
import 'package:anwarsajadia/features/tools/presentation/screens/contact_screen.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/screens/bookmarks_screen.dart';
import 'package:anwarsajadia/features/search/presentation/screens/global_search_screen.dart';
import 'package:anwarsajadia/features/home/presentation/screens/activities_screen.dart';
import 'package:anwarsajadia/features/home/presentation/screens/news_screen.dart';
import 'package:anwarsajadia/features/home/presentation/screens/occasions_screen.dart';
import 'package:anwarsajadia/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:anwarsajadia/features/settings/presentation/screens/about_app_screen.dart';
import 'package:anwarsajadia/features/settings/presentation/screens/about_foundation_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// انتقال صفحة بتلاشٍ. نمرّر `name` حتى يفرّق الـNavigator بين صفحتين من نفس
/// النوع — بدونه ينفجر go_router 14.x بتأكيد «مفاتيح مكرّرة» داخل
/// HeroControllerScope لمّا تتشارك مسارات عليا نفس parentNavigatorKey.
CustomTransitionPage<void> _buildPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: state.name,
    arguments: state.extra,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      return FadeTransition(opacity: fadeAnimation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

GoRouter createAppRouter() => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RoutePaths.splash,
  routes: [
    // شاشة البداية
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      pageBuilder: (context, state) => _buildPage(const SplashScreen(), state),
    ),

    // البحث الشامل — مسار أعلى، ينفتح فوق كل شي
    GoRoute(
      path: '/search',
      name: RouteNames.globalSearch,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          _buildPage(const GlobalSearchScreen(), state),
    ),

    // المحفوظات
    GoRoute(
      path: '/bookmarks',
      name: RouteNames.bookmarks,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          _buildPage(const BookmarksScreen(), state),
    ),

    // الإشعارات
    GoRoute(
      path: '/notifications',
      name: RouteNames.notifications,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          _buildPage(const NotificationsScreen(), state),
    ),

    // عن التطبيق
    GoRoute(
      path: '/about-app',
      name: RouteNames.aboutApp,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          _buildPage(const AboutAppScreen(), state),
    ),

    // عن المؤسسة
    GoRoute(
      path: '/about-foundation',
      name: RouteNames.aboutFoundation,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          _buildPage(const AboutFoundationScreen(), state),
    ),

    // قارئ الـPDF الداخلي. الرابط والعنوان يمرّان بـ`extra` لا بالمسار: الروابط
    // طويلة وفيها محارف تحتاج ترميزاً، وتلزيقها بالمسار يكسرها.
    GoRoute(
      path: '/pdf',
      name: RouteNames.pdfReader,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final data = state.extra is Map
            ? (state.extra! as Map).cast<String, String>()
            : const <String, String>{};
        return _buildPage(
          PdfReaderScreen(url: data['url'] ?? '', title: data['title'] ?? ''),
          state,
        );
      },
    ),

    // الشهداء
    GoRoute(
      path: '/martyrs',
      name: RouteNames.martyrs,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          _buildPage(const MartyrsListScreen(), state),
      routes: [
        GoRoute(
          path: ':martyrId',
          name: RouteNames.martyrDetail,
          parentNavigatorKey: _rootNavigatorKey,
          pageBuilder: (context, state) {
            final id =
                int.tryParse(state.pathParameters['martyrId'] ?? '') ?? 0;
            return _buildPage(MartyrDetailScreen(martyrId: id), state);
          },
        ),
      ],
    ),

    // الزيارة بالإنابة
    GoRoute(
      path: '/visit-by-proxy',
      name: RouteNames.visitByProxy,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          _buildPage(const VisitByProxyScreen(), state),
    ),

    // القشرة الرئيسية بتبويباتها
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeScreen(navigationShell: navigationShell),
      branches: [
        // تبويب 0: الرئيسية
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.home,
              name: RouteNames.home,
              builder: (context, state) => const HomeTabScreen(),
              routes: [
                GoRoute(
                  path: 'activities',
                  name: RouteNames.activities,
                  builder: (context, state) => const ActivitiesScreen(),
                ),
                GoRoute(
                  path: 'news',
                  name: RouteNames.news,
                  builder: (context, state) => const NewsScreen(),
                ),
                GoRoute(
                  path: 'occasions',
                  name: RouteNames.occasions,
                  builder: (context, state) => const OccasionsScreen(),
                ),
              ],
            ),
          ],
        ),

        // تبويب 1: القرآن
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.quran,
              name: RouteNames.quran,
              builder: (context, state) => const SurahListScreen(),
              routes: [
                GoRoute(
                  path: 'surah/:surahId',
                  name: RouteNames.surahReading,
                  builder: (context, state) {
                    final surahId = int.parse(state.pathParameters['surahId']!);
                    return QuranReadingScreen(surahId: surahId);
                  },
                ),
                GoRoute(
                  path: 'search',
                  name: RouteNames.quranSearch,
                  builder: (context, state) => const QuranSearchScreen(),
                ),
              ],
            ),
          ],
        ),

        // تبويب 2: السجادية
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.sajjad,
              name: RouteNames.sajjad,
              builder: (context, state) => const SajjadHomeScreen(),
              routes: [
                GoRoute(
                  path: 'biography',
                  name: RouteNames.biography,
                  builder: (context, state) => const BiographyScreen(),
                ),
                GoRoute(
                  path: 'book/:bookId',
                  name: RouteNames.bookChapters,
                  builder: (context, state) {
                    final bookId = int.parse(state.pathParameters['bookId']!);
                    return BookChaptersScreen(bookId: bookId);
                  },
                  routes: [
                    GoRoute(
                      path: 'chapter/:chapterId',
                      name: RouteNames.chapterReading,
                      builder: (context, state) {
                        final chapterId = int.parse(
                          state.pathParameters['chapterId']!,
                        );
                        final subjectParam =
                            state.uri.queryParameters['subject'];
                        final subjectIndex = subjectParam != null
                            ? int.tryParse(subjectParam)
                            : null;
                        return ChapterReadingScreen(
                          chapterId: chapterId,
                          initialSubjectIndex: subjectIndex,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'sahifa-explained',
                  name: RouteNames.sahifaExplained,
                  builder: (context, state) => const SahifaExplainedScreen(),
                  routes: [
                    GoRoute(
                      path: 'prayer/:prayerNumber',
                      name: RouteNames.sahifaPrayerReading,
                      builder: (context, state) {
                        final prayerNumber = int.parse(
                          state.pathParameters['prayerNumber']!,
                        );
                        return SahifaPrayerReadingScreen(
                          prayerNumber: prayerNumber,
                        );
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'ziyarat',
                  name: RouteNames.ziyaratList,
                  builder: (context, state) => const ZiyaratListScreen(),
                ),
                GoRoute(
                  path: 'ziyara/:ziyaraId',
                  name: RouteNames.ziyaraReading,
                  builder: (context, state) {
                    final ziyaraId = int.parse(
                      state.pathParameters['ziyaraId']!,
                    );
                    return ZiyaraReadingScreen(ziyaraId: ziyaraId);
                  },
                ),
                GoRoute(
                  path: 'maqamat',
                  name: RouteNames.maqamat,
                  builder: (context, state) => const MaqamatScreen(),
                  routes: [
                    GoRoute(
                      path: 'maqam/:maqamId',
                      name: RouteNames.maqamDetail,
                      builder: (context, state) {
                        final maqamId = int.parse(
                          state.pathParameters['maqamId']!,
                        );
                        return MaqamDetailScreen(maqamId: maqamId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // تبويب 3: الوسائط
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.media,
              name: RouteNames.media,
              builder: (context, state) => const MultimediaHomeScreen(),
              routes: [
                GoRoute(
                  path: 'videos',
                  name: RouteNames.videoList,
                  builder: (context, state) => const VideoListScreen(),
                ),
                GoRoute(
                  path: 'playlist/:playlistId',
                  name: RouteNames.videoPlaylist,
                  builder: (context, state) => VideoPlaylistScreen(
                    playlistId: state.pathParameters['playlistId']!,
                    title:
                        state.uri.queryParameters['title'] ?? 'قائمة التشغيل',
                  ),
                ),
                GoRoute(
                  path: 'watch/:videoId',
                  name: RouteNames.youtubePlayer,
                  builder: (context, state) => YoutubeVideoScreen(
                    videoId: state.pathParameters['videoId']!,
                    title: state.uri.queryParameters['title'] ?? '',
                  ),
                ),
                GoRoute(
                  path: 'video/:videoId',
                  name: RouteNames.videoPlayer,
                  builder: (context, state) {
                    final videoId = int.parse(state.pathParameters['videoId']!);
                    return VideoPlayerScreen(videoId: videoId);
                  },
                ),
                GoRoute(
                  path: 'audios',
                  name: RouteNames.audioList,
                  builder: (context, state) => const AudioListScreen(),
                ),
                GoRoute(
                  path: 'audio-player',
                  name: RouteNames.audioPlayer,
                  builder: (context, state) => const AudioPlayerScreen(),
                ),
                GoRoute(
                  path: 'photos',
                  name: RouteNames.photoGallery,
                  builder: (context, state) => const PhotoGalleryScreen(),
                ),
              ],
            ),
          ],
        ),

        // تبويب 4: المزيد (الأدوات والخدمات)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.more,
              name: RouteNames.more,
              builder: (context, state) => const ToolsHomeScreen(),
              routes: [
                GoRoute(
                  path: 'qibla',
                  name: RouteNames.qibla,
                  builder: (context, state) => const QiblaScreen(),
                ),
                GoRoute(
                  path: 'quiz',
                  name: RouteNames.quiz,
                  // بفيغما «المسابقات» تفتح قائمة مسابقات، والضغط على وحدة
                  // يفتح أسئلتها بالمسار الفرعي `play` — حتى يرجع زر الرجوع
                  // للقائمة ولا يطلّع من التطبيق.
                  builder: (context, state) => const QuizListScreen(),
                  routes: [
                    GoRoute(
                      path: 'play',
                      name: RouteNames.quizPlay,
                      builder: (context, state) => const QuizScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'contact',
                  name: RouteNames.contact,
                  builder: (context, state) => const ContactScreen(),
                ),
              ],
            ),
          ],
        ),

        // تبويب 5: المكتبة — فرع مستقل حتى يحتفظ بمكدّسه مثل بقية التبويبات
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.library,
              name: RouteNames.library,
              builder: (context, state) => const LibraryScreen(),
              routes: [
                GoRoute(
                  path: 'specialized',
                  name: RouteNames.specializedLibrary,
                  builder: (context, state) => const SpecializedLibraryScreen(),
                ),
                GoRoute(
                  path: 'publications',
                  name: RouteNames.publications,
                  builder: (context, state) => const PublicationsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
