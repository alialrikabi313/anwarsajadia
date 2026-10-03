// المواقع المقدّسة اللي تشير لها البوصلة: الكعبة والمراقد.
//
// الإحداثيات مقرَّرة ومراجَعة، وما تنحسب ولا تنجلب من خدمة خارجية — الاتجاه
// للمرقد أمر ديني، وخطأ درجة بيه ما ينغتفر.

import 'package:flutter/material.dart';

enum HolySiteCategory { qibla, prophet, imam }

class HolySite {
  const HolySite({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.icon = Icons.mosque,
  });

  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final HolySiteCategory category;
  final IconData icon;
}

const holySites = <HolySite>[
  // ── القبلة والنبي (صلى الله عليه وآله وسلم) ──
  HolySite(
    id: 'kaaba',
    name: 'الكعبة المشرفة',
    location: 'مكة المكرمة',
    latitude: 21.4225,
    longitude: 39.8262,
    category: HolySiteCategory.qibla,
  ),
  HolySite(
    id: 'prophet',
    name: 'قبر النبي (صلى الله عليه وآله وسلم)',
    location: 'المدينة المنورة',
    latitude: 24.4672,
    longitude: 39.6112,
    category: HolySiteCategory.prophet,
  ),

  // ── أئمة أهل البيت عليهم السلام ──
  HolySite(
    id: 'imam_ali',
    name: 'الإمام علي (ع)',
    location: 'النجف الأشرف - العراق',
    latitude: 32.0075,
    longitude: 44.3148,
    category: HolySiteCategory.imam,
  ),
  HolySite(
    id: 'imam_hasan',
    name: 'الإمام الحسن (ع)',
    location: 'البقيع - المدينة المنورة',
    latitude: 24.4674,
    longitude: 39.6134,
    category: HolySiteCategory.imam,
  ),
  HolySite(
    id: 'imam_husayn',
    name: 'الإمام الحسين (ع)',
    location: 'كربلاء المقدسة - العراق',
    latitude: 32.6165,
    longitude: 44.0235,
    category: HolySiteCategory.imam,
  ),
  HolySite(
    id: 'imam_sajjad',
    name: 'الإمام السجاد (ع)',
    location: 'البقيع - المدينة المنورة',
    latitude: 24.4674,
    longitude: 39.6134,
    category: HolySiteCategory.imam,
  ),
  HolySite(
    id: 'imam_baqir',
    name: 'الإمام الباقر (ع)',
    location: 'البقيع - المدينة المنورة',
    latitude: 24.4674,
    longitude: 39.6134,
    category: HolySiteCategory.imam,
  ),
  HolySite(
    id: 'imam_sadiq',
    name: 'الإمام الصادق (ع)',
    location: 'البقيع - المدينة المنورة',
    latitude: 24.4674,
    longitude: 39.6134,
    category: HolySiteCategory.imam,
  ),
  HolySite(
    id: 'imam_kadhim',
    name: 'الإمام الكاظم (ع)',
    location: 'الكاظمية - بغداد',
    latitude: 33.3811,
    longitude: 44.3399,
    category: HolySiteCategory.imam,
  ),
  HolySite(
    id: 'imam_ridha',
    name: 'الإمام الرضا (ع)',
    location: 'مشهد المقدسة - إيران',
    latitude: 36.2882,
    longitude: 59.6157,
    category: HolySiteCategory.imam,
  ),
  HolySite(
    id: 'imam_jawad',
    name: 'الإمام الجواد (ع)',
    location: 'الكاظمية - بغداد',
    latitude: 33.3811,
    longitude: 44.3399,
    category: HolySiteCategory.imam,
  ),
  HolySite(
    id: 'imam_hadi',
    name: 'الإمام الهادي (ع)',
    location: 'سامراء - العراق',
    latitude: 34.1982,
    longitude: 43.8715,
    category: HolySiteCategory.imam,
  ),
  HolySite(
    id: 'imam_askari',
    name: 'الإمام العسكري (ع)',
    location: 'سامراء - العراق',
    latitude: 34.1982,
    longitude: 43.8715,
    category: HolySiteCategory.imam,
  ),
];
