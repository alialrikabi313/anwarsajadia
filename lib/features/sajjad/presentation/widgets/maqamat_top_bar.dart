// رأس قسم المقامات المشترك بين شاشتي القائمة والمقام المفرد — مطابق للتصميم
// المعتمد: العنوان «مقامات الامـــام» وتحته خط فاصل، ثم صفّ واحد فيه سهم
// الرجوع (أقصى اليمين) ثم حقل البحث ثم حبّة القلب (أقصى اليسار).

import 'package:flutter/material.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/core/widgets/app_search_field.dart';

class MaqamatSectionHeader extends StatelessWidget {
  const MaqamatSectionHeader({
    required this.onSearchChanged,
    required this.favoriteActive,
    required this.onFavoriteTap,
    super.key,
    this.searchController,
    this.searchTrailing = const [],
  });

  final ValueChanged<String> onSearchChanged;
  final TextEditingController? searchController;

  /// عناصر تلحق داخل الحقل (عدّاد المطابقات وسهما التنقّل بصفحة المقام).
  final List<Widget> searchTrailing;

  /// القلب مضاء: «المفضّلة فقط» بالقائمة، و«هذا المقام مفضّل» بصفحته.
  final bool favoriteActive;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // العنوان بتباعد حروف واسع كما بالتصميم.
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
          child: Text(
            'مقامات الامـــام',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Inter',
              fontFamilyFallback: kArabicFontFallback,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 0.8,
            color: AppColors.borderLight.withValues(alpha: 0.55),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          // مع RTL أول عنصر يقع أقصى اليمين: السهم، ثم فاصل رأسي، ثم الحقل،
          // ثم القلب في الطرف الأيسر — تماماً كالتصميم.
          child: Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 6),
              Container(
                width: 1.2,
                height: 30,
                color: AppColors.borderLight.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppSearchField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  trailing: searchTrailing,
                ),
              ),
              const SizedBox(width: 10),
              _FavoritePill(
                active: favoriteActive,
                onTap: onFavoriteTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// حبّة القلب الرملية في طرف صفّ البحث.
class _FavoritePill extends StatelessWidget {
  const _FavoritePill({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 62,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.olive : AppColors.medallionSand,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          active ? Icons.favorite_rounded : Icons.favorite_rounded,
          size: 20,
          color: active ? AppColors.cream : AppColors.primary,
        ),
      ),
    );
  }
}
