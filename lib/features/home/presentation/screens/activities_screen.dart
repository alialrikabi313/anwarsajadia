// شاشة «النشاطات»: منشورات المؤسسة المصنّفة نشاطات.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/helpers/share_helper.dart';
import 'package:anwarsajadia/features/home/data/models/post_model.dart';
import 'package:anwarsajadia/features/home/presentation/providers/posts_provider.dart';

class ActivitiesScreen extends ConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final postsAsync = ref.watch(activityPostsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.foundationActivities),
          centerTitle: true,
        ),
        body: postsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'تعذّر تحميل النشاطات: $e',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 14,
                ),
              ),
            ),
          ),
          data: (posts) {
            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد نشاطات متاحة حالياً',
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 14,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _ExpandableActivityCard(post: posts[index]),
            );
          },
        ),
      ),
    );
  }
}

class _ExpandableActivityCard extends StatefulWidget {
  const _ExpandableActivityCard({required this.post});

  final FoundationPost post;

  @override
  State<_ExpandableActivityCard> createState() =>
      _ExpandableActivityCardState();
}

class _ExpandableActivityCardState extends State<_ExpandableActivityCard> {
  bool _expanded = false;

  String get _plainDescription =>
      widget.post.content.replaceAll(RegExp(r'<[^>]+>'), ' ').replaceAll(
            RegExp(r'\s+'),
            ' ',
          ).trim();

  void _copyContent() {
    final p = widget.post;
    final text = '${p.title}\n${p.date}\n\n$_plainDescription';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم النسخ')),
    );
  }

  void _shareContent() {
    final p = widget.post;
    ShareHelper.shareText(
      '${p.title}\n\n$_plainDescription',
      title: p.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.post;
    final body = _plainDescription;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event,
                      size: 20,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.title,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.accentGoldDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    p.date,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 12,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedCrossFade(
                firstChild: Text(
                  p.summary.isNotEmpty ? p.summary : body,
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 14,
                    height: 1.7,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      body,
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 14,
                        height: 1.7,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: _copyContent,
                          icon: const Icon(Icons.copy, size: 18),
                          label: const Text(
                            'نسخ',
                            style: TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: _shareContent,
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text(
                            'مشاركة',
                            style: TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                crossFadeState: _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 250),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
