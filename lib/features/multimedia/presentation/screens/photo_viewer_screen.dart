// صفحة عرض الصورة: شاشة مستقلة لا نافذة منبثقة — زر الرجوع وإيماءة السحب
// من الحافة يشتغلان طبيعياً.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/helpers/share_helper.dart';
import 'package:anwarsajadia/core/utils/helpers/url_helper.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/multimedia_providers.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

/// عرض صورة المعرض بحجمها الكامل مع التكبير باللمس، والتنقّل بالسحب بين
/// الصور، وبياناتها، وزرَّي التنزيل والمشاركة.
class PhotoViewerScreen extends ConsumerStatefulWidget {
  const PhotoViewerScreen({required this.initialIndex, super.key});

  final int initialIndex;

  @override
  ConsumerState<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends ConsumerState<PhotoViewerScreen> {
  late final PageController _pc = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  static bool _isAsset(String url) => url.startsWith('assets/');

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(photosProvider(null));

    return Scaffold(
      backgroundColor: Colors.black,
      body: photosAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white70)),
        error: (_, __) => const Center(
          child: Text('تعذّر تحميل الصورة',
              style: TextStyle(color: Colors.white70)),
        ),
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(
              child: Text('لا توجد صور',
                  style: TextStyle(color: Colors.white70)),
            );
          }
          final i = _index.clamp(0, photos.length - 1);
          final photo = photos[i];
          return SafeArea(
            child: Column(
              children: [
                // شريط علوي: رجوع (يمين) + العدّاد.
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Text(
                          '${i + 1} من ${photos.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontFamilyFallback: kArabicFontFallback,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                // الصورة: سحب أفقي للتالية/السابقة + تكبير باللمس.
                Expanded(
                  child: PageView.builder(
                    controller: _pc,
                    itemCount: photos.length,
                    onPageChanged: (v) => setState(() => _index = v),
                    itemBuilder: (context, k) {
                      final url = photos[k].imageUrl;
                      return InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Center(
                          child: _isAsset(url)
                              ? Image.asset(url, fit: BoxFit.contain)
                              : CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.contain,
                                  placeholder: (_, __) => const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white54, strokeWidth: 2),
                                  ),
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white24,
                                    size: 60,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
                // بيانات الصورة وأزرارها.
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          photo.title,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontFamilyFallback: kArabicFontFallback,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // المصدر — البند الثاني من «بيانات الصورة» في ملاحظة 14.
                        // كل صور المعرض من إنتاج المؤسسة نفسها، مضمّنةً كانت
                        // أو مجلوبة من الخادم.
                        Row(
                          children: [
                            const Icon(Icons.verified_outlined,
                                color: AppColors.mediaGold, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'المصدر: مؤسسة الإمام زين العابدين (عليه السلام)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'NotoNaskhArabic',
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: AppColors.mediaGold, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              _fmtDate(photo.publishedAt),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontFamilyFallback: kArabicFontFallback,
                                fontSize: 12.5,
                                color: Colors.white70,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'تنزيل',
                              icon: const Icon(Icons.file_download_outlined,
                                  color: AppColors.mediaGold),
                              onPressed: () => _isAsset(photo.imageUrl)
                                  ? UrlHelper.saveAssetImage(
                                      context, photo.imageUrl, photo.title)
                                  : UrlHelper.downloadMedia(
                                      context, photo.imageUrl, photo.title),
                            ),
                            IconButton(
                              tooltip: 'مشاركة',
                              icon: const Icon(Icons.share_rounded,
                                  color: AppColors.mediaGold),
                              onPressed: () => ShareHelper.shareText(
                                photo.title,
                                title: 'أنوار السجادية',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
