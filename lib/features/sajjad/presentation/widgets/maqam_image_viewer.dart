// عارض صورة المقام: زر الصورة في بطاقة المقام وصفحته يفتح الصورة بحجمها
// الكامل مع التكبير باللمس، بدل أن يكون زخرفة لا تفعل شيئاً.

import 'package:flutter/material.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/maqamat_list_provider.dart';

Future<void> showMaqamImage(BuildContext context, MaqamIndexEntry maqam) {
  if (maqam.image.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'لا توجد صورة لهذا المقام بعد',
          textDirection: TextDirection.rtl,
          style: TextStyle(fontFamily: 'NotoNaskhArabic'),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
    return Future<void>.value();
  }
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Flexible(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(maqam.image, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              maqam.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: kArabicFontFallback,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
