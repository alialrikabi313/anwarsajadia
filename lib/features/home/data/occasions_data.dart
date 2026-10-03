// مناسبات أهل البيت (عليهم السلام) بتواريخها الهجرية.
//
// التواريخ هنا مقرَّرة لا محسوبة، ومراجعتها ترجع لصاحب المشروع — النظام ينقل
// ولا يجتهد بتاريخ ولادة أو شهادة.

import 'package:anwarsajadia/features/home/domain/entities/occasion.dart';

/// كل المناسبات بتواريخ هجرية موثّقة.
///
/// أرقام الأشهر: 1=محرم 2=صفر 3=ربيع الأول 4=ربيع الثاني
/// 5=جمادى الأولى 6=جمادى الآخرة 7=رجب 8=شعبان
/// 9=رمضان 10=شوال 11=ذو القعدة 12=ذو الحجة
const allOccasions = <AhlulBaytOccasion>[
  // ── محرم ──
  AhlulBaytOccasion(
    name: 'الإمام الحسين (ع)',
    title: 'شهادة الإمام الحسين (ع)',
    hijriMonth: 1,
    hijriDay: 10,
    type: OccasionType.martyrdom,
  ),
  AhlulBaytOccasion(
    name: 'الإمام زين العابدين (ع)',
    title: 'شهادة الإمام السجاد (ع)',
    hijriMonth: 1,
    hijriDay: 25,
    type: OccasionType.martyrdom,
  ),

  // ── صفر ──
  AhlulBaytOccasion(
    name: 'النبي محمد (صلى الله عليه وآله وسلم)',
    title: 'وفاة النبي الأعظم (صلى الله عليه وآله وسلم)',
    hijriMonth: 2,
    hijriDay: 28,
    type: OccasionType.martyrdom,
  ),
  AhlulBaytOccasion(
    name: 'الإمام الحسن (ع)',
    title: 'شهادة الإمام الحسن المجتبى (ع)',
    hijriMonth: 2,
    hijriDay: 7,
    type: OccasionType.martyrdom,
  ),
  AhlulBaytOccasion(
    name: 'الإمام الرضا (ع)',
    title: 'شهادة الإمام الرضا (ع)',
    hijriMonth: 2,
    hijriDay: 17,
    type: OccasionType.martyrdom,
    note: 'وقيل في آخر صفر',
  ),
  AhlulBaytOccasion(
    name: 'الإمام الكاظم (ع)',
    title: 'ولادة الإمام الكاظم (ع)',
    hijriMonth: 2,
    hijriDay: 7,
    type: OccasionType.birth,
  ),

  // ── ربيع الأول ──
  AhlulBaytOccasion(
    name: 'النبي محمد (صلى الله عليه وآله وسلم)',
    title: 'ولادة النبي الأعظم (صلى الله عليه وآله وسلم)',
    hijriMonth: 3,
    hijriDay: 17,
    type: OccasionType.birth,
  ),
  AhlulBaytOccasion(
    name: 'الإمام الصادق (ع)',
    title: 'ولادة الإمام الصادق (ع)',
    hijriMonth: 3,
    hijriDay: 17,
    type: OccasionType.birth,
  ),
  AhlulBaytOccasion(
    name: 'الإمام العسكري (ع)',
    title: 'شهادة الإمام العسكري (ع)',
    hijriMonth: 3,
    hijriDay: 8,
    type: OccasionType.martyrdom,
  ),

  // ── ربيع الثاني ──
  AhlulBaytOccasion(
    name: 'الإمام العسكري (ع)',
    title: 'ولادة الإمام العسكري (ع)',
    hijriMonth: 4,
    hijriDay: 8,
    type: OccasionType.birth,
  ),

  // ── جمادى الآخرة ──
  AhlulBaytOccasion(
    name: 'فاطمة الزهراء (ع)',
    title: 'ولادة السيدة الزهراء (ع)',
    hijriMonth: 6,
    hijriDay: 20,
    type: OccasionType.birth,
  ),
  AhlulBaytOccasion(
    name: 'فاطمة الزهراء (ع)',
    title: 'شهادة السيدة الزهراء (ع)',
    hijriMonth: 6,
    hijriDay: 3,
    type: OccasionType.martyrdom,
    note: 'وقيل ١٣ جمادى الأولى',
  ),

  // ── رجب ──
  AhlulBaytOccasion(
    name: 'الإمام علي (ع)',
    title: 'ولادة أمير المؤمنين (ع)',
    hijriMonth: 7,
    hijriDay: 13,
    type: OccasionType.birth,
  ),
  AhlulBaytOccasion(
    name: 'الإمام الباقر (ع)',
    title: 'ولادة الإمام الباقر (ع)',
    hijriMonth: 7,
    hijriDay: 1,
    type: OccasionType.birth,
  ),
  AhlulBaytOccasion(
    name: 'الإمام الجواد (ع)',
    title: 'ولادة الإمام الجواد (ع)',
    hijriMonth: 7,
    hijriDay: 10,
    type: OccasionType.birth,
  ),
  AhlulBaytOccasion(
    name: 'الإمام الهادي (ع)',
    title: 'شهادة الإمام الهادي (ع)',
    hijriMonth: 7,
    hijriDay: 3,
    type: OccasionType.martyrdom,
  ),
  AhlulBaytOccasion(
    name: 'الإمام الكاظم (ع)',
    title: 'شهادة الإمام الكاظم (ع)',
    hijriMonth: 7,
    hijriDay: 25,
    type: OccasionType.martyrdom,
  ),

  // ── شعبان ──
  AhlulBaytOccasion(
    name: 'الإمام الحسين (ع)',
    title: 'ولادة الإمام الحسين (ع)',
    hijriMonth: 8,
    hijriDay: 3,
    type: OccasionType.birth,
  ),
  AhlulBaytOccasion(
    name: 'الإمام زين العابدين (ع)',
    title: 'ولادة الإمام السجاد (ع)',
    hijriMonth: 8,
    hijriDay: 5,
    type: OccasionType.birth,
  ),
  AhlulBaytOccasion(
    name: 'الإمام المهدي (عج)',
    title: 'ولادة الإمام المهدي (عج)',
    hijriMonth: 8,
    hijriDay: 15,
    type: OccasionType.birth,
  ),

  // ── رمضان ──
  AhlulBaytOccasion(
    name: 'الإمام علي (ع)',
    title: 'شهادة أمير المؤمنين (ع)',
    hijriMonth: 9,
    hijriDay: 21,
    type: OccasionType.martyrdom,
  ),
  AhlulBaytOccasion(
    name: 'الإمام الحسن (ع)',
    title: 'ولادة الإمام الحسن المجتبى (ع)',
    hijriMonth: 9,
    hijriDay: 15,
    type: OccasionType.birth,
  ),

  // ── شوال ──
  AhlulBaytOccasion(
    name: 'الإمام الصادق (ع)',
    title: 'شهادة الإمام الصادق (ع)',
    hijriMonth: 10,
    hijriDay: 25,
    type: OccasionType.martyrdom,
  ),

  // ── ذو القعدة ──
  AhlulBaytOccasion(
    name: 'الإمام الرضا (ع)',
    title: 'ولادة الإمام الرضا (ع)',
    hijriMonth: 11,
    hijriDay: 11,
    type: OccasionType.birth,
  ),
  AhlulBaytOccasion(
    name: 'الإمام الجواد (ع)',
    title: 'شهادة الإمام الجواد (ع)',
    hijriMonth: 11,
    hijriDay: 29,
    type: OccasionType.martyrdom,
    note: 'وقيل في آخر ذي القعدة',
  ),

  // ── ذو الحجة ──
  AhlulBaytOccasion(
    name: 'الإمام الباقر (ع)',
    title: 'شهادة الإمام الباقر (ع)',
    hijriMonth: 12,
    hijriDay: 7,
    type: OccasionType.martyrdom,
  ),
  AhlulBaytOccasion(
    name: 'الإمام الهادي (ع)',
    title: 'ولادة الإمام الهادي (ع)',
    hijriMonth: 12,
    hijriDay: 15,
    type: OccasionType.birth,
    note: 'وقيل ٢ رجب',
  ),
];
