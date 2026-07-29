// معرض الصور: شبكة مصغّرات تنفتح بملء الشاشة.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/photo_item.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/multimedia_providers.dart';

class PhotoGalleryScreen extends ConsumerWidget {
  const PhotoGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final photosAsync = ref.watch(photosProvider(null));

    return Scaffold(
      backgroundColor: AppColors.mediaBg,
      appBar: AppBar(
        backgroundColor: AppColors.mediaBg,
        foregroundColor: Colors.white,
        title: Text(
          l10n.mediaPhotos,
          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: photosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'تعذّر تحميل الصور: $e',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          ),
        ),
        data: (photos) {
          if (photos.isEmpty) {
            return Center(
              child: Text(
                l10n.mediaNoItems,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: Colors.white70),
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return _PhotoTile(photo: photos[index]);
            },
          );
        },
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo});

  final PhotoItem photo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreen(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.charcoalDeep,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            // تحميل كسول: المربّع ما ينبني إلا لمّا يوصل للشاشة، والصورة
            // تُفكّ بمقاس المصغّرة وتنخبّى على القرص، ويظهر بديل أثناء الجلب —
            // بلا هذا يبلع المعرض الذاكرة.
            if (photo.imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: photo.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 300,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, __) => const Center(
                  child: Icon(
                    Icons.photo_outlined,
                    size: 36,
                    color: Colors.white24,
                  ),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 36,
                    color: Colors.white24,
                  ),
                ),
              )
            else
              const Center(
                child: Icon(
                  Icons.photo_outlined,
                  size: 36,
                  color: Colors.white24,
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Text(
                  photo.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreen(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.charcoalDeep,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 420),
                width: double.infinity,
                color: AppColors.charcoalDarker,
                child: photo.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photo.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white54,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const SizedBox(
                          height: 300,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 64,
                            color: Colors.white24,
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 300,
                        child: Icon(
                          Icons.image,
                          size: 64,
                          color: Colors.white24,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                photo.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
