import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../models/mizan_models.dart';

class _MethodParams {
  final double fajrAngle;
  final double ishaAngle;
  final int? ishaIntervalMinutes;
  final double? maghribAngle;

  const _MethodParams({
    required this.fajrAngle,
    required this.ishaAngle,
    this.ishaIntervalMinutes,
    this.maghribAngle,
  });
}

class AdhanPrayerService {
  static const double _d2r = math.pi / 180.0;
  static const double _r2d = 180.0 / math.pi;

  static const Map<CalculationMethod, _MethodParams> _methodConfig = {
    CalculationMethod.mwl: _MethodParams(fajrAngle: 18.0, ishaAngle: 17.0),
    CalculationMethod.isna: _MethodParams(fajrAngle: 15.0, ishaAngle: 15.0),
    CalculationMethod.egypt: _MethodParams(fajrAngle: 19.5, ishaAngle: 17.5),
    CalculationMethod.makkah:
        _MethodParams(fajrAngle: 18.5, ishaAngle: 0.0, ishaIntervalMinutes: 90),
    CalculationMethod.karachi: _MethodParams(fajrAngle: 18.0, ishaAngle: 18.0),
    CalculationMethod.tehran:
        _MethodParams(fajrAngle: 17.7, ishaAngle: 14.0, maghribAngle: 4.5),
    CalculationMethod.jafari:
        _MethodParams(fajrAngle: 16.0, ishaAngle: 14.0, maghribAngle: 4.0),
  };

  static const List<CityLocation> presetCities = [
    CityLocation(
        name: 'Makkah',
        country: 'Saudi Arabia',
        lat: 21.4225,
        lng: 39.8262,
        timezoneOffset: 3.0),
    CityLocation(
        name: 'Madinah',
        country: 'Saudi Arabia',
        lat: 24.4686,
        lng: 39.6142,
        timezoneOffset: 3.0),
    CityLocation(
        name: 'Jerusalem',
        country: 'Palestine',
        lat: 31.7683,
        lng: 35.2137,
        timezoneOffset: 2.0),
    CityLocation(
        name: 'London',
        country: 'United Kingdom',
        lat: 51.5074,
        lng: -0.1278,
        timezoneOffset: 0.0),
    CityLocation(
        name: 'New York',
        country: 'United States',
        lat: 40.7128,
        lng: -74.006,
        timezoneOffset: -5.0),
    CityLocation(
        name: 'Cairo',
        country: 'Egypt',
        lat: 30.0444,
        lng: 31.2357,
        timezoneOffset: 2.0),
    CityLocation(
        name: 'Istanbul',
        country: 'Turkey',
        lat: 41.0082,
        lng: 28.9784,
        timezoneOffset: 3.0),
    CityLocation(
        name: 'Jakarta',
        country: 'Indonesia',
        lat: -6.2088,
        lng: 106.8456,
        timezoneOffset: 7.0),
    CityLocation(
        name: 'Kuala Lumpur',
        country: 'Malaysia',
        lat: 3.139,
        lng: 101.6869,
        timezoneOffset: 8.0),
    CityLocation(
        name: 'Toronto',
        country: 'Canada',
        lat: 43.6532,
        lng: -79.3832,
        timezoneOffset: -5.0),
    CityLocation(
        name: 'Dubai',
        country: 'United Arab Emirates',
        lat: 25.2048,
        lng: 55.2708,
        timezoneOffset: 4.0),
  ];

  static double _sinD(double deg) => math.sin(deg * _d2r);
  static double _cosD(double deg) => math.cos(deg * _d2r);
  static double _tanD(double deg) => math.tan(deg * _d2r);
  static double _asinD(double v) => math.asin(v.clamp(-1.0, 1.0)) * _r2d;
  static double _acosD(double v) => math.acos(v.clamp(-1.0, 1.0)) * _r2d;
  static double _atan2D(double y, double x) => math.atan2(y, x) * _r2d;

  /// Offline mathematical astronomical calculation (identical to Adhan / Batoul Apps)
  static PrayerCalculationOutput calculatePrayerTimes({
    required CityLocation city,
    DateTime? nowOverride,
    CalculationMethod method = CalculationMethod.mwl,
    AsrMethod madhab = AsrMethod.shafi,
  }) {
    final now = nowOverride ?? DateTime.now();
    final year = now.year;
    final month = now.month;
    final day = now.day;

    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    final jd = day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;

    final d = jd - 2451545.0;
    final g = (357.529 + 0.98560028 * d) % 360.0;
    final q = (280.459 + 0.98564736 * d) % 360.0;
    final l = (q + 1.915 * _sinD(g) + 0.02 * _sinD(2 * g)) % 360.0;
    final e = 23.439 - 0.00000036 * d;

    final declination = _asinD(_sinD(e) * _sinD(l));
    final ra = _atan2D(_cosD(e) * _sinD(l), _cosD(l)) / 15.0;
    final eqTime = (q / 15.0 - (ra < 0 ? ra + 24.0 : ra)) * 60.0;

    final tzOffset = now.timeZoneOffset.inMinutes / 60.0;
    final solarNoon =
        12.0 + tzOffset - city.lng / 15.0 - eqTime / 60.0;

    final lat = city.lat;
    final dec = declination;
    final params = _methodConfig[method]!;

    double hourAngle(double altitude) {
      final cosHa =
          (_sinD(altitude) - _sinD(lat) * _sinD(dec)) /
              (_cosD(lat) * _cosD(dec));
      if (cosHa > 1.0 || cosHa < -1.0) return 0.0;
      return _acosD(cosHa) / 15.0;
    }

    final fajrHours = solarNoon - hourAngle(-params.fajrAngle);
    final sunriseHours = solarNoon - hourAngle(-0.8333);
    final dhuhrHours = solarNoon + 2.0 / 60.0;

    final shadowFactor = madhab == AsrMethod.hanafi ? 2.0 : 1.0;
    final asrAlt =
        _atan2D(1.0, shadowFactor + _tanD((lat - dec).abs()));
    final asrHours = solarNoon + hourAngle(asrAlt);

    final maghribAngle =
        params.maghribAngle != null ? -params.maghribAngle! : -0.8333;
    final maghribHours = solarNoon + hourAngle(maghribAngle);

    final double ishaHours = params.ishaIntervalMinutes != null
        ? maghribHours + params.ishaIntervalMinutes! / 60.0
        : solarNoon + hourAngle(-params.ishaAngle);

    DateTime hoursToDate(double hours) {
      final wholeH = hours.floor();
      final totalMins = ((hours - wholeH) * 60.0);
      final mins = totalMins.floor();
      final secs = ((totalMins - mins) * 60.0).floor();
      return DateTime(year, month, day, wholeH, mins, secs);
    }

    final rawList = [
      ('Fajr', 'الفجر', hoursToDate(fajrHours)),
      ('Sunrise', 'الشروق', hoursToDate(sunriseHours)),
      ('Dhuhr', 'الظهر', hoursToDate(dhuhrHours)),
      ('Asr', 'العصر', hoursToDate(asrHours)),
      ('Maghrib', 'المغرب', hoursToDate(maghribHours)),
      ('Isha', 'العشاء', hoursToDate(ishaHours)),
    ];

    int nextIdx = 0;
    bool afterIsha = false;
    for (int i = 0; i < rawList.length; i++) {
      if (now.isBefore(rawList[i].$3)) {
        nextIdx = i;
        break;
      }
      if (i == rawList.length - 1) {
        afterIsha = true;
        nextIdx = 0;
      }
    }

    final fmt12 = DateFormat('h:mm a');
    final fmt24 = DateFormat('HH:mm');

    final prayers = <PrayerTimeEntry>[];
    for (int i = 0; i < rawList.length; i++) {
      final item = rawList[i];
      prayers.add(PrayerTimeEntry(
        name: item.$1,
        arabicName: item.$2,
        time12: fmt12.format(item.$3),
        time24: fmt24.format(item.$3),
        dateObj: item.$3,
        isNext: !afterIsha && i == nextIdx,
      ));
    }

    PrayerTimeEntry nextPrayer;
    if (afterIsha) {
      final tomorrowFajr = rawList[0].$3.add(const Duration(days: 1));
      nextPrayer = PrayerTimeEntry(
        name: 'Fajr',
        arabicName: 'الفجر',
        time12: fmt12.format(tomorrowFajr),
        time24: fmt24.format(tomorrowFajr),
        dateObj: tomorrowFajr,
        isNext: true,
      );
      prayers[0] = nextPrayer;
    } else {
      nextPrayer = prayers[nextIdx];
    }

    final diff = nextPrayer.dateObj.difference(now);
    final totalSecs = math.max(0, diff.inSeconds);
    final h = totalSecs ~/ 3600;
    final min = (totalSecs % 3600) ~/ 60;
    final sec = totalSecs % 60;
    final countdownString =
        h > 0 ? '${h}h ${min}m ${sec}s' : '${min}m ${sec}s';

    // Qibla direction toward Kaaba (21.422487 N, 39.826206 E)
    const kaabaLat = 21.422487;
    const kaabaLng = 39.826206;
    final deltaLng = (kaabaLng - city.lng) * _d2r;
    final yQ = math.sin(deltaLng);
    final xQ = math.cos(city.lat * _d2r) * math.tan(kaabaLat * _d2r) -
        math.sin(city.lat * _d2r) * math.cos(deltaLng);
    var qibla = math.atan2(yQ, xQ) * _r2d;
    if (qibla < 0) qibla += 360.0;

    return PrayerCalculationOutput(
      prayers: prayers,
      nextPrayer: nextPrayer,
      countdownString: countdownString,
      qiblaBearing: qibla.roundToDouble(),
    );
  }
}
