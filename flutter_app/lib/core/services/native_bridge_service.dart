import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

class NativeBridgeService {
  NativeBridgeService._();
  static final NativeBridgeService instance = NativeBridgeService._();

  static const MethodChannel _shieldChannel =
      MethodChannel('com.mizan.wellbeing/shield');
  static const MethodChannel _usageChannel =
      MethodChannel('com.mizan.wellbeing/usage');
  static const MethodChannel _reminderChannel =
      MethodChannel('com.mizan.wellbeing/reminders');
  static const EventChannel _triggerEventChannel =
      EventChannel('com.mizan.wellbeing/triggers');

  Future<bool> hasNotificationPermission() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        return await _reminderChannel
                .invokeMethod<bool>('hasNotificationPermission') ??
            false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestNotificationPermission() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _reminderChannel.invokeMethod('requestNotificationPermission');
    } catch (_) {}
  }

  Future<void> showGoalReminderNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _reminderChannel.invokeMethod('showGoalReminderNotification', {
        'id': id,
        'title': title,
        'body': body,
      });
    } catch (_) {}
  }

  Future<bool> checkPermissions() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        final bool hasAccessibility =
            await _shieldChannel.invokeMethod<bool>('isAccessibilityEnabled') ??
                false;
        final bool hasOverlay =
            await _shieldChannel.invokeMethod<bool>('hasOverlayPermission') ??
                false;
        final bool hasUsageStats =
            await _usageChannel.invokeMethod<bool>('hasUsageStatsPermission') ??
                false;
        return hasAccessibility && hasOverlay && hasUsageStats;
      } else if (Platform.isIOS) {
        final bool isAuthorized =
            await _shieldChannel.invokeMethod<bool>('isScreenTimeAuthorized') ??
                false;
        return isAuthorized;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  Future<void> requestAndroidPermissions() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      await _shieldChannel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  Future<bool> requestIOSScreenTimeAuth() async {
    if (kIsWeb || !Platform.isIOS) return false;
    try {
      final bool? success =
          await _shieldChannel.invokeMethod<bool>('requestFamilyControls');
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateSalahLockSchedule({
    required DateTime nextPrayerTime,
    required String prayerName,
    required int leadMinutes,
  }) async {
    if (kIsWeb) return;
    try {
      await _shieldChannel.invokeMethod('scheduleSalahLock', {
        'prayerName': prayerName,
        'timestamp': nextPrayerTime.millisecondsSinceEpoch,
        'leadMinutes': leadMinutes,
      });
    } catch (_) {}
  }

  Stream<dynamic> get interventionStream =>
      _triggerEventChannel.receiveBroadcastStream();
}
