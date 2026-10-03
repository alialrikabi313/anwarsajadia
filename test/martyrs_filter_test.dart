// martyrsProvider يستثني الشهداء ناقصي البيانات: اسمٌ بلا صورة، أو صورةٌ بلا
// اسم، أو «سيرة» ليست إلا تاريخَي ولادةٍ واستشهاد — كلها تُنتج بطاقةً مكسورة
// بدل سيرة. الاختبار يستدعي `isMartyrComplete` نفسها لا نسخةً موازية منها.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:anwarsajadia/features/martyrs/domain/entities/martyr.dart';
import 'package:anwarsajadia/features/martyrs/presentation/providers/martyrs_provider.dart';

/// سيرةٌ حقيقية بطولٍ يتجاوز الحدّ.
const _fullBio =
    'ولد في مدينة البصرة، ونشأ في أسرة علمية، ودرس المقدّمات في الحوزة '
    'العلمية ثم هاجر إلى النجف الأشرف لإكمال دراسته. عُرف بالزهد والتقوى، '
    'وكان خطيباً مفوَّهاً يؤمّ الناس في مسجد محلّته. لبّى نداء الفتوى '
    'المباركة فالتحق بصفوف المجاهدين، واستُشهد في معركة تحرير المدينة بعد '
    'قتالٍ شديد، وشيّعه أهالي مدينته تشييعاً مهيباً.';

Martyr _martyr({
  int id = 1,
  String name = 'الشهيد فلان الفلاني',
  String? photo = 'assets/images/martyrs/1.jpg',
  String bio = _fullBio,
}) =>
    Martyr(
      id: id,
      name: name,
      title: 'الشهيد',
      birthDate: '',
      martyrdomDate: '',
      bio: bio,
      photo: photo,
    );

void main() {
  test('اسمٌ وصورةٌ وسيرةٌ كاملة يُقبل', () {
    expect(isMartyrComplete(_martyr()), isTrue);
  });

  test('اسمٌ بلا صورة يُستبعد', () {
    expect(isMartyrComplete(_martyr(photo: null)), isFalse);
    expect(isMartyrComplete(_martyr(photo: '   ')), isFalse);
  });

  test('صورةٌ بلا اسم تُستبعد', () {
    expect(isMartyrComplete(_martyr(name: '')), isFalse);
    expect(isMartyrComplete(_martyr(name: '   ')), isFalse);
  });

  test('سيرةٌ ليست إلا تاريخين تُستبعد', () {
    expect(
      isMartyrComplete(_martyr(
        bio: 'التولد: بغداد _ 1982 الاستشهاد: ٦-١١-١٤٣٦ه 2015/8/22_سامراء',
      )),
      isFalse,
    );
    expect(isMartyrComplete(_martyr(bio: '')), isFalse);
  });

  group('المصدر الحقيقي', () {
    late List<Martyr> all;

    setUpAll(() {
      final raw = File('assets/data/martyrs.json').readAsStringSync();
      all = (json.decode(raw) as List<dynamic>)
          .map((e) => Martyr.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    test('حارس رجعي: ٦٤ سجلّاً يبقى منها ٥٢ كاملاً', () {
      expect(all.length, 64, reason: 'إجمالي سجلّات الناشر تغيّر عن المتوقَّع');
      expect(
        all.where(isMartyrComplete).length,
        52,
        reason: 'عدد الشهداء كاملي البيانات تغيّر — راجع assets/data/martyrs.json',
      );
    });

    test('السبعة أصحاب السيرة المبتورة مستبعدون بأعيانهم', () {
      const excludedIds = {26, 27, 31, 32, 34, 35, 66};
      final shownIds = all.where(isMartyrComplete).map((m) => m.id).toSet();
      expect(shownIds.intersection(excludedIds), isEmpty);
      // وموجودون في المصدر أصلاً — كي لا ينجح الاختبار لمجرّد اختفاء المعرّفات.
      expect(all.map((m) => m.id).toSet().containsAll(excludedIds), isTrue);
    });
  });
}
