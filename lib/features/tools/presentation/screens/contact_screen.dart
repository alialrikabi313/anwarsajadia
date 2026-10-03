// شاشة «اتصل بنا»: نموذج يُرسل للخادم بعد تحقّق محلي من الصيغ.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/network/api_client.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/core/utils/validators.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _message.text.trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('يرجى تعبئة الاسم والبريد والرسالة',
              textDirection: TextDirection.rtl),
        ),
      );
      return;
    }
    if (!isEmail(_email.text)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('البريد الإلكتروني غير صحيح',
              textDirection: TextDirection.rtl),
        ),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      // نموذج الخادم ما بيه حقل «الموضوع»، فندمجه بمتن الرسالة حتى ما يضيع.
      final subject = _subject.text.trim();
      final body = subject.isEmpty
          ? _message.text.trim()
          : '$subject\n\n${_message.text.trim()}';
      await ref.read(apiClientProvider).postJson('/forms/contact', {
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'message': body,
      });
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.toolsContactSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      _name.clear();
      _email.clear();
      _subject.clear();
      _message.clear();
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
          content: Text('تعذّر إرسال الرسالة، تحقّق من الاتصال',
              textDirection: TextDirection.rtl),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.toolsContact),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الترويسة
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.cyanDark,
                    AppColors.cyan,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.toolsContact,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontFamilyFallback: kArabicFontFallback,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // حقل الاسم
            _buildTextField(
              controller: _name,
              label: l10n.toolsContactName,
              icon: Icons.person_outline,
              theme: theme,
            ),
            const SizedBox(height: 16),
            // حقل البريد
            _buildTextField(
              controller: _email,
              label: l10n.toolsContactEmail,
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              theme: theme,
            ),
            const SizedBox(height: 16),
            // حقل الموضوع
            _buildTextField(
              controller: _subject,
              label: l10n.toolsContactSubject,
              icon: Icons.subject,
              theme: theme,
            ),
            const SizedBox(height: 16),
            // حقل الرسالة
            _buildTextField(
              controller: _message,
              label: l10n.toolsContactMessage,
              icon: Icons.message_outlined,
              maxLines: 5,
              theme: theme,
            ),
            const SizedBox(height: 24),
            // زر الإرسال
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _sending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _sending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send),
                          const SizedBox(width: 8),
                          Text(
                            l10n.toolsContactSend,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'NotoNaskhArabic'),
        prefixIcon: Icon(icon, color: AppColors.cyan),
        filled: true,
        fillColor: AppColors.cyan.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.cyan.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.cyan.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.cyan,
            width: 2,
          ),
        ),
      ),
      style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
      textDirection: TextDirection.rtl,
    );
  }
}
