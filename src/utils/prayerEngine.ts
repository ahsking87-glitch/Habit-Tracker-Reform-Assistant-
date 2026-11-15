import { CalculationMethod, Coordinates, Madhab, PrayerTimesResult } from '../types';

// Mathematical constants
const D2R = Math.PI / 180;
const R2D = 180 / Math.PI;

function sinD(deg: number): number {
  return Math.sin(deg * D2R);
}
function cosD(deg: number): number {
  return Math.cos(deg * D2R);
}
function tanD(deg: number): number {
  return Math.tan(deg * D2R);
}
function asinD(val: number): number {
  return Math.asin(Math.max(-1, Math.min(1, val))) * R2D;
}
function acosD(val: number): number {
  return Math.acos(Math.max(-1, Math.min(1, val))) * R2D;
}
function atan2D(y: number, x: number): number {
  return Math.atan2(y, x) * R2D;
}

// Astronomical calculation parameters per calculation method
interface MethodParams {
  fajrAngle: number;
  ishaAngle: number;
  ishaInterval?: number; // Minutes after Maghrib (e.g. Makkah uses 90 min)
  maghribAngle?: number;
}

const METHOD_CONFIG: Record<CalculationMethod, MethodParams> = {
  MWL: { fajrAngle: 18.0, ishaAngle: 17.0 },
  ISNA: { fajrAngle: 15.0, ishaAngle: 15.0 },
  EGYPT: { fajrAngle: 19.5, ishaAngle: 17.5 },
  MAKKAH: { fajrAngle: 18.5, ishaAngle: 0, ishaInterval: 90 },
  KARACHI: { fajrAngle: 18.0, ishaAngle: 18.0 },
  TEHRAN: { fajrAngle: 17.7, ishaAngle: 14.0, maghribAngle: 4.5 },
  JAFARI: { fajrAngle: 16.0, ishaAngle: 14.0, maghribAngle: 4.0 },
};

/**
 * Calculates offline prayer times using standard astronomical solar coordinates
 * Identical algorithm to the open-source Adhan library (Batoul Apps)
 */
export function calculatePrayerTimes(
  coords: Coordinates,
  date: Date = new Date(),
  method: CalculationMethod = 'MWL',
  madhab: Madhab = 'SHAFI'
): PrayerTimesResult {
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();

  // Julian date calculation
  const a = Math.floor((14 - month) / 12);
  const y = year + 4800 - a;
  const m = month + 12 * a - 3;
  let jd =
    day +
    Math.floor((153 * m + 2) / 5) +
    365 * y +
    Math.floor(y / 4) -
    Math.floor(y / 100) +
    Math.floor(y / 400) -
    32045;

  const d = jd - 2451545.0; // Days since J2000.0

  // Solar coordinates
  const g = (357.529 + 0.98560028 * d) % 360;
  const q = (280.459 + 0.98564736 * d) % 360;
  const L = (q + 1.915 * sinD(g) + 0.02 * sinD(2 * g)) % 360;
  const e = 23.439 - 0.00000036 * d; // Obliquity of ecliptic

  const declination = asinD(sinD(e) * sinD(L));
  const RA = atan2D(cosD(e) * sinD(L), cosD(L)) / 15;
  const equationOfTime = (q / 15 - (RA < 0 ? RA + 24 : RA)) * 60; // in minutes

  // Timezone offset in hours
  const timezoneOffsetHours = -date.getTimezoneOffset() / 60;

  // Solar noon in hours local time
  const solarNoonHours = 12 + timezoneOffsetHours - coords.longitude / 15 - equationOfTime / 60;

  const lat = coords.latitude;
  const dec = declination;
  const params = METHOD_CONFIG[method];

  // Helper to compute hour angle from altitude angle
  function hourAngle(altitude: number): number {
    const cosHA = (sinD(altitude) - sinD(lat) * sinD(dec)) / (cosD(lat) * cosD(dec));
    if (cosHA > 1 || cosHA < -1) return 0; // Polar anomaly
    return acosD(cosHA) / 15;
  }

  // Fajr: Sun is at negative fajrAngle
  const fajrHA = hourAngle(-params.fajrAngle);
  const fajrHours = solarNoonHours - fajrHA;

  // Sunrise: Sun is at -0.8333 degrees (accounting for atmospheric refraction and solar radius)
  const sunriseHA = hourAngle(-0.8333);
  const sunriseHours = solarNoonHours - sunriseHA;

  // Dhuhr: Solar noon + 2 min buffer (Zawāl safety)
  const dhuhrHours = solarNoonHours + 2 / 60;

  // Asr: Shadow length factor: Shafi = 1, Hanafi = 2
  const shadowFactor = madhab === 'HANAFI' ? 2 : 1;
  const asrAltitude = atan2D(1, shadowFactor + tanD(Math.abs(lat - dec)));
  const asrHA = hourAngle(asrAltitude);
  const asrHours = solarNoonHours + asrHA;

  // Maghrib: Sun at -0.8333 or specific angle for Jafari/Tehran
  const maghribAngle = params.maghribAngle ? -params.maghribAngle : -0.8333;
  const maghribHA = hourAngle(maghribAngle);
  const maghribHours = solarNoonHours + maghribHA;

  // Isha
  let ishaHours: number;
  if (params.ishaInterval) {
    ishaHours = maghribHours + params.ishaInterval / 60;
  } else {
    const ishaHA = hourAngle(-params.ishaAngle);
    ishaHours = solarNoonHours + ishaHA;
  }

  // Convert decimal hours to Date objects for the given date
  function hoursToDate(hours: number): Date {
    const dObj = new Date(date);
    dObj.setSeconds(0);
    dObj.setMilliseconds(0);
    const wholeHours = Math.floor(hours);
    const minutes = Math.floor((hours - wholeHours) * 60);
    const seconds = Math.floor(((hours - wholeHours) * 60 - minutes) * 60);
    dObj.setHours(wholeHours, minutes, seconds);
    return dObj;
  }

  const fajr = hoursToDate(fajrHours);
  const sunrise = hoursToDate(sunriseHours);
  const dhuhr = hoursToDate(dhuhrHours);
  const asr = hoursToDate(asrHours);
  const maghrib = hoursToDate(maghribHours);
  const isha = hoursToDate(ishaHours);

  // Qibla direction calculation (from coordinates to Kaaba: 21.4225° N, 39.8262° E)
  const kaabaLat = 21.422487;
  const kaabaLng = 39.826206;
  const deltaLng = (kaabaLng - coords.longitude) * D2R;
  const yQibla = Math.sin(deltaLng);
  const xQibla =
    Math.cos(coords.latitude * D2R) * Math.tan(kaabaLat * D2R) -
    Math.sin(coords.latitude * D2R) * Math.cos(deltaLng);
  let qiblaDegrees = Math.atan2(yQibla, xQibla) * R2D;
  if (qiblaDegrees < 0) qiblaDegrees += 360;

  // Determine current and next prayer
  const now = date.getTime();
  const prayers = [
    { name: 'Fajr', arabicName: 'الفجر', time: fajr },
    { name: 'Sunrise', arabicName: 'الشروق', time: sunrise },
    { name: 'Dhuhr', arabicName: 'الظهر', time: dhuhr },
    { name: 'Asr', arabicName: 'العصر', time: asr },
    { name: 'Maghrib', arabicName: 'المغرب', time: maghrib },
    { name: 'Isha', arabicName: 'العشاء', time: isha },
  ];

  let nextPrayer = prayers[0];
  let currentPrayer = prayers[prayers.length - 1];

  for (let i = 0; i < prayers.length; i++) {
    if (now < prayers[i].time.getTime()) {
      nextPrayer = prayers[i];
      currentPrayer = i > 0 ? prayers[i - 1] : prayers[prayers.length - 1];
      break;
    }
  }

  // If after Isha, next prayer is Fajr tomorrow
  if (now >= isha.getTime()) {
    const tomorrowFajr = new Date(fajr);
    tomorrowFajr.setDate(tomorrowFajr.getDate() + 1);
    nextPrayer = {
      name: 'Fajr',
      arabicName: 'الفجر',
      time: tomorrowFajr,
    };
    currentPrayer = {
      name: 'Isha',
      arabicName: 'العشاء',
      time: isha,
    };
  }

  const remainingMs = Math.max(0, nextPrayer.time.getTime() - now);

  return {
    fajr,
    sunrise,
    dhuhr,
    asr,
    maghrib,
    isha,
    nextPrayer: {
      ...nextPrayer,
      remainingMs,
    },
    currentPrayer: {
      name: currentPrayer.name,
      arabicName: currentPrayer.arabicName,
    },
    qiblaDegrees: Math.round(qiblaDegrees),
  };
}

// Preset cities with accurate coordinates
export const PRESET_CITIES: Coordinates[] = [
  { city: 'Makkah', country: 'Saudi Arabia', latitude: 21.4225, longitude: 39.8262 },
  { city: 'Madinah', country: 'Saudi Arabia', latitude: 24.4686, longitude: 39.6142 },
  { city: 'Jerusalem', country: 'Palestine', latitude: 31.7683, longitude: 35.2137 },
  { city: 'London', country: 'United Kingdom', latitude: 51.5074, longitude: -0.1278 },
  { city: 'New York', country: 'United States', latitude: 40.7128, longitude: -74.006 },
  { city: 'Cairo', country: 'Egypt', latitude: 30.0444, longitude: 31.2357 },
  { city: 'Istanbul', country: 'Turkey', latitude: 41.0082, longitude: 28.9784 },
  { city: 'Jakarta', country: 'Indonesia', latitude: -6.2088, longitude: 106.8456 },
  { city: 'Kuala Lumpur', country: 'Malaysia', latitude: 3.139, longitude: 101.6869 },
  { city: 'Toronto', country: 'Canada', latitude: 43.6532, longitude: -79.3832 },
  { city: 'Dubai', country: 'United Arab Emirates', latitude: 25.2048, longitude: 55.2708 },
];

export function formatTime(date: Date): string {
  return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

export function formatDuration(ms: number): string {
  const totalSeconds = Math.floor(ms / 1000);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  if (hours > 0) {
    return `${hours}h ${minutes}m ${seconds}s`;
  }
  return `${minutes}m ${seconds}s`;
}
