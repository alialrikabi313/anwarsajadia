// مزوّدات البوصلة: الموقع، اتجاه الجهاز، الموقع المختار، وزاوية الإبرة.

import 'dart:math';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:anwarsajadia/features/tools/data/geomag_service.dart';
import 'package:anwarsajadia/features/tools/domain/entities/holy_site.dart';

// ── الموقع ────────────────────────────────────────────────────

/// موقع المستخدم الحالي، ويطلب الإذن إذا لزم.
final userLocationProvider = FutureProvider<Position>((ref) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw const LocationServiceDisabledException();
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw PermissionDeniedException('Location permission denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw PermissionDeniedException('Location permission permanently denied');
  }

  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );
});

// ── البوصلة ───────────────────────────────────────────────────

/// يبثّ اتجاه بوصلة الجهاز بالدرجات (0–360، و0 = الشمال).
final compassHeadingProvider = StreamProvider<double>((ref) {
  return FlutterCompass.events!.where((e) => e.heading != null).map(
        (e) => e.heading!,
      );
});

// ── الموقع المختار ────────────────────────────────────────────

/// الموقع المقدّس المختار حالياً — الكعبة افتراضاً.
final selectedSiteProvider = StateProvider<HolySite>(
  (ref) => holySites.first, // الكعبة المشرفة
);

// ── حساب الاتجاه ──────────────────────────────────────────────

/// الاتجاه الجغرافي بالدرجات من موقع المستخدم للموقع المختار، بمعادلة
/// السمت الأمامي.
final bearingToSiteProvider = Provider<double?>((ref) {
  final locationAsync = ref.watch(userLocationProvider);
  final site = ref.watch(selectedSiteProvider);

  return locationAsync.whenData((pos) {
    return _calculateBearing(
      pos.latitude,
      pos.longitude,
      site.latitude,
      site.longitude,
    );
  }).value;
});

/// المسافة بالكيلومترات من المستخدم للموقع المختار.
final distanceToSiteProvider = Provider<double?>((ref) {
  final locationAsync = ref.watch(userLocationProvider);
  final site = ref.watch(selectedSiteProvider);

  return locationAsync.whenData((pos) {
    return _calculateDistance(
      pos.latitude,
      pos.longitude,
      site.latitude,
      site.longitude,
    );
  }).value;
});

/// الانحراف المغناطيسي المحلي (بالدرجات، الموجب = شرقاً) عند موقع المستخدم.
/// بيه نحوّل اتجاه الشمال المغناطيسي إلى شمال حقيقي، ويرجع لصفر لمّا ما يتوفّر.
final magneticDeclinationProvider = FutureProvider<double>((ref) async {
  final pos = ref.watch(userLocationProvider).valueOrNull;
  if (pos == null) return 0;
  return GeomagService.declination(pos.latitude, pos.longitude, pos.altitude);
});

/// الزاوية اللي لازم تشير لها الإبرة.
///
/// تحسب اتجاه الجهاز نفسه حتى تبقى الإبرة على الهدف مهما أدار المستخدم هاتفه،
/// وتصحّح الاتجاه المغناطيسي بالانحراف المحلي حتى تتبع الشمال الحقيقي.
///
/// المعادلة: زاوية الإبرة = الاتجاه للموقع − (اتجاه البوصلة + الانحراف)
final compassNeedleAngleProvider = Provider<double?>((ref) {
  final bearing = ref.watch(bearingToSiteProvider);
  final headingAsync = ref.watch(compassHeadingProvider);
  final declination = ref.watch(magneticDeclinationProvider).valueOrNull ?? 0;

  if (bearing == null) return null;

  return headingAsync.whenData((heading) {
    return bearing - heading - declination;
  }).value;
});

// ── بوصلة الرئيسية (سلبية — ما تطلب إذناً أبداً) ───────────────

/// الموقع بلا طلب إذن: يرجّع قراءة بس إذا كان الإذن ممنوحاً أصلاً.
///
/// بيه تشتغل بوصلة الرئيسية بصمت بعد ما يمنح المستخدم الإذن من شاشة القبلة،
/// بلا ما نفاجئه بطلب إذن على الشاشة الرئيسية نفسها.
final passiveLocationProvider = FutureProvider<Position?>((ref) async {
  if (!await Geolocator.isLocationServiceEnabled()) return null;
  final perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied ||
      perm == LocationPermission.deniedForever) {
    return null;
  }
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );
});

final _passiveDeclinationProvider = FutureProvider<double>((ref) async {
  final pos = ref.watch(passiveLocationProvider).valueOrNull;
  if (pos == null) return 0;
  return GeomagService.declination(pos.latitude, pos.longitude, pos.altitude);
});

/// زاوية إبرة بوصلة الرئيسية نحو إحداثيات كيفما كانت (الاتجاه المعروض
/// بالكاروسيل). تبقى null لحد ما يُمنح الإذن ويتوفّر اتجاه.
final homeNeedleToTargetProvider =
    Provider.family<double?, ({double lat, double lng})>((ref, target) {
  final pos = ref.watch(passiveLocationProvider).valueOrNull;
  if (pos == null) return null;
  final declination = ref.watch(_passiveDeclinationProvider).valueOrNull ?? 0;
  final bearing = _calculateBearing(
    pos.latitude,
    pos.longitude,
    target.lat,
    target.lng,
  );
  return ref.watch(compassHeadingProvider).whenData((heading) {
    // نقرّب لدرجتين: بثّ الحسّاس ~33 مرة بالثانية وبيه ضجيج، وبلا التقريب
    // تنعاد بناء بطاقة الرئيسية بكل إطار. والإبرة تبقى تتحرّك بسلاسة.
    final angle = bearing - heading - declination;
    return (angle / 2).roundToDouble() * 2;
  }).value;
});

// ── مساعدات هافرساين ──────────────────────────────────────────

double _toRadians(double degrees) => degrees * pi / 180;
double _toDegrees(double radians) => radians * 180 / pi;

/// السمت الأمامي (الاتجاه الابتدائي) من نقطة لنقطة.
double _calculateBearing(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  final phi1 = _toRadians(lat1);
  final phi2 = _toRadians(lat2);
  final deltaLambda = _toRadians(lon2 - lon1);

  final y = sin(deltaLambda) * cos(phi2);
  final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);

  final bearing = _toDegrees(atan2(y, x));
  return (bearing + 360) % 360; // Normalize to 0–360
}

/// مسافة الدائرة العظمى بالكيلومترات بمعادلة هافرساين.
double _calculateDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earthRadiusKm = 6371.0;

  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadiusKm * c;
}

/// تسمية عربية مقروءة لاتجاه بالدرجات.
String bearingToDirection(double bearing) {
  final normalized = bearing % 360;
  if (normalized >= 337.5 || normalized < 22.5) return 'شمال';
  if (normalized < 67.5) return 'شمال شرق';
  if (normalized < 112.5) return 'شرق';
  if (normalized < 157.5) return 'جنوب شرق';
  if (normalized < 202.5) return 'جنوب';
  if (normalized < 247.5) return 'جنوب غرب';
  if (normalized < 292.5) return 'غرب';
  return 'شمال غرب';
}
