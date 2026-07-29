// جسر لنموذج المجال المغناطيسي بالمنصّة.

import 'package:flutter/services.dart';

// جسر لنموذج المجال المغناطيسي بالمنصّة.

/// نجيب منه الانحراف المغناطيسي المحلي، حتى تصحّح بوصلة القبلة اتجاه
/// المغناطيسية (الشمال المغناطيسي) إلى الشمال الحقيقي — الفرق بينهما يوصل
/// درجات، وبالقبلة هذا فرق يهمّ.
class GeomagService {
  const GeomagService._();

  static const MethodChannel _channel = MethodChannel('anwarsajadia/geomag');

  /// الانحراف المغناطيسي بالدرجات (الموجب = شرقاً) عند [lat]/[lon].
  ///
  /// يعتمد على `GeomagneticField` بأندرويد. يرجّع `0.0` لمّا ما يتوفّر (iOS،
  /// محاكي، أو أي عطل) فيرجع المنادي للاتجاه المغناطيسي الخام بلا انكسار.
  static Future<double> declination(
    double lat,
    double lon, [
    double alt = 0,
  ]) async {
    try {
      final value = await _channel.invokeMethod<double>('declination', {
        'lat': lat,
        'lon': lon,
        'alt': alt,
      });
      return value ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }
}
