// قارئ PDF داخل التطبيق.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:anwarsajadia/core/network/api_client.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';

// قارئ PDF داخل التطبيق.

/// ينزّل ملف الكتاب مرة وحدة ويخبّيه، ويعرضه بـ[PDFView] مع أدوات قراءة كاملة:
/// عدّاد صفحات ومنزلق قفز، التالي والسابق، الأول والأخير، تبديل اتجاه التمرير،
/// وتكبير بالقرص (مدمج). ويعرض رسالة صريحة إذا كان الملف مفقوداً على الخادم.
class PdfReaderScreen extends StatefulWidget {
  const PdfReaderScreen({required this.url, required this.title, super.key});

  final String url;
  final String title;

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  String? _filePath;
  String? _error;

  PDFViewController? _controller;
  int _pages = 0;
  int _current = 0;
  bool _horizontal = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.url.isEmpty) {
      setState(() => _error = 'الرابط غير متوفر');
      return;
    }
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/book_${widget.url.hashCode}.pdf');
      if (await file.exists() && await file.length() > 1000) {
        if (mounted) setState(() => _filePath = file.path);
        return;
      }
      final res = await http
          .get(Uri.parse(widget.url),
              headers: const {'User-Agent': kBrowserUserAgent})
          .timeout(const Duration(seconds: 60));
      final type = (res.headers['content-type'] ?? '').toLowerCase();
      if (res.statusCode != 200 ||
          !(type.contains('pdf') || type.contains('octet-stream'))) {
        setState(() => _error = 'الكتاب غير متوفر على الخادم حالياً');
        return;
      }
      // نرفض التنزيل المبتور: ملف ناقص ينخبّى معناها الكتاب ما ينفتح أبداً
      // بعدها، والمستخدم ما يعرف ليش.
      final expected = int.tryParse(res.headers['content-length'] ?? '');
      if (expected != null && res.bodyBytes.length < expected) {
        setState(
            () => _error = 'تعذّر فتح الكتاب، تحقّق من الاتصال');
        return;
      }
      await file.writeAsBytes(res.bodyBytes);
      if (mounted) setState(() => _filePath = file.path);
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذّر فتح الكتاب، تحقّق من الاتصال');
    }
  }

  /// الملف المخبّأ اللي ما يفتحه PDFView (تنزيل ناقص أو تالف) ننحذفه، حتى
  /// الفتحة الجاية تنزّله من جديد بدل ما تعلق على نفس العطل.
  Future<void> _onPdfBroken() async {
    try {
      if (_filePath != null) await File(_filePath!).delete();
    } catch (_) {}
    if (mounted) {
      setState(() {
        _filePath = null;
        _error = 'الملف تالف — أعد فتح الكتاب لإعادة تنزيله';
      });
    }
  }

  void _goTo(int page) {
    final p = page.clamp(0, _pages > 0 ? _pages - 1 : 0);
    _controller?.setPage(p);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mediaSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_ready)
            IconButton(
              tooltip: _horizontal ? 'تمرير عمودي' : 'تمرير أفقي',
              icon: Icon(_horizontal
                  ? Icons.swap_vert_rounded
                  : Icons.swap_horiz_rounded),
              onPressed: () => setState(() => _horizontal = !_horizontal),
            ),
        ],
      ),
      body: _error != null
          ? _message(_error!)
          : _filePath == null
              ? _loading()
              : Column(
                  children: [
                    Expanded(
                      child: PDFView(
                        // المفتاح يجبر إعادة البناء عند قلب اتجاه التمرير.
                        key: ValueKey(_horizontal),
                        filePath: _filePath,
                        swipeHorizontal: _horizontal,
                        autoSpacing: true,
                        pageSnap: true,
                        pageFling: true,
                        onRender: (pages) => setState(() {
                          _pages = pages ?? 0;
                          _ready = true;
                        }),
                        onViewCreated: (c) => _controller = c,
                        onError: (_) => _onPdfBroken(),
                        onPageChanged: (page, total) => setState(() {
                          _current = page ?? 0;
                          _pages = total ?? _pages;
                        }),
                      ),
                    ),
                    if (_ready && _pages > 0) _controls(),
                  ],
                ),
    );
  }

  Widget _controls() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _iconBtn(Icons.first_page_rounded, () => _goTo(0)),
              _iconBtn(Icons.chevron_left_rounded, () => _goTo(_current + 1)),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.cardOliveMuted,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppColors.cardOliveMuted,
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 7),
                  ),
                  child: Slider(
                    min: 0,
                    max: (_pages - 1).toDouble().clamp(0, double.infinity),
                    value: _current
                        .toDouble()
                        .clamp(0, (_pages - 1).toDouble()),
                    onChanged: (v) => _goTo(v.round()),
                  ),
                ),
              ),
              _iconBtn(Icons.chevron_right_rounded, () => _goTo(_current - 1)),
              _iconBtn(Icons.last_page_rounded, () => _goTo(_pages - 1)),
            ],
          ),
          Text(
            'صفحة ${_current + 1} من $_pages',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: 24,
        visualDensity: VisualDensity.compact,
        onPressed: onTap,
      );

  Widget _loading() => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white70),
            SizedBox(height: 14),
            Text('جارٍ فتح الكتاب…',
                style: TextStyle(
                    fontFamily: 'NotoNaskhArabic', color: Colors.white70)),
          ],
        ),
      );

  Widget _message(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.picture_as_pdf_outlined,
                  color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    color: Colors.white70,
                    fontSize: 15),
              ),
            ],
          ),
        ),
      );
}
