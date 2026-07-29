// شاشة «الزيارة بالإنابة».

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/network/api_client.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/validators.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';

/// نموذج تسجيل: اسم وهاتف ودولة، يُرسَل للخادم عبر
/// `POST /forms/proxy-visit`.
class VisitByProxyScreen extends ConsumerStatefulWidget {
  const VisitByProxyScreen({super.key});

  @override
  ConsumerState<VisitByProxyScreen> createState() =>
      _VisitByProxyScreenState();
}

class _VisitByProxyScreenState extends ConsumerState<VisitByProxyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _country = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _country.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _submitting = true);
    try {
      await ref.read(apiClientProvider).postJson('/forms/proxy-visit', {
        'visitor_name': _name.text.trim(),
        'visitor_phone': _phone.text.trim(),
        // الخادم يشترط رمز دولة ISO-2 بحرفين كبار مثل IQ.
        'visitor_country': _country.text.trim().toUpperCase(),
      });

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'تم تسجيل طلب الزيارة بالإنابة — جزاكم الله خيراً',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
      _formKey.currentState?.reset();
      _name.clear();
      _email.clear();
      _phone.clear();
      _country.clear();
    } on ApiException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.displayMessage, textDirection: TextDirection.rtl),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'تعذّر إرسال الطلب، تحقّق من الاتصال',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.readingSand,
        body: Stack(
          children: [
            // ميداليات زهرية باهتة تنزف من الزاوية العليا اليسرى والسفلى
            // اليمنى، بدرجة قريبة من الرملي فتبان نسيجاً لا شكلاً.
            const Positioned(
              left: -120,
              top: 36,
              width: 300,
              child: IgnorePointer(
                child: Image(
                  image: AssetImage(
                    'assets/figma_assets/proxy_corner_ornament.png',
                  ),
                ),
              ),
            ),
            const Positioned(
              right: -120,
              bottom: 20,
              width: 300,
              child: IgnorePointer(
                child: Image(
                  image: AssetImage(
                    'assets/figma_assets/proxy_corner_ornament.png',
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const HomeHeader(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.primary),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        'طلب الزيارة بالانابة',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                    decoration: BoxDecoration(
                      // بطاقة رمادية دافئة بحدّ أبيض ونصف قطر 20.7.
                      color: AppColors.occasionCard,
                      borderRadius: BorderRadius.circular(20.7),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 2.4,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'سجل اسمك',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.surfaceNearBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'لكي يتم الزيارة بالإنابة عنك',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 12,
                              color: AppColors.ornamentInk,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _Field(
                            controller: _name,
                            hint: 'الاسم الكامل',
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'الاسم مطلوب'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          _Field(
                            controller: _email,
                            hint: 'الإيميل (اختياري)',
                            keyboardType: TextInputType.emailAddress,
                            // الخادم ما يستعمله — نبقيه اختيارياً.
                            validator: (v) =>
                                (v == null || v.trim().isEmpty || isEmail(v))
                                    ? null
                                    : 'البريد الإلكتروني غير صحيح',
                          ),
                          const SizedBox(height: 10),
                          _Field(
                            controller: _phone,
                            hint: 'الهاتف (+9647…)',
                            keyboardType: TextInputType.phone,
                            validator: (v) =>
                                (v == null || !isE164Phone(v))
                                    ? 'الهاتف بصيغة دولية مثل ‎+9647801234567'
                                    : null,
                          ),
                          const SizedBox(height: 10),
                          _Field(
                            controller: _country,
                            hint: 'رمز الدولة (مثل IQ)',
                            validator: (v) => (v == null ||
                                    !RegExp(r'^[A-Za-z]{2}$').hasMatch(v.trim()))
                                ? 'رمز الدولة بحرفين مثل IQ'
                                : null,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.frameGrayDark,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.7),
                                ),
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'سجل',
                                      style: TextStyle(
                                        fontFamily: 'NotoNaskhArabic',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 13,
          color: AppColors.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 13,
            color: AppColors.textMutedLight,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          border: InputBorder.none,
          errorStyle: const TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
