import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _legacyAthanChannelId = 'athan_channel';
  static const String _legacyPrayerChannelId = 'prayer_channel';
  static const String _deprecatedAthanChannelId = 'athan_channel_v2';
  static const String _deprecatedPrayerChannelId = 'prayer_channel_v2';
  static const String _deprecatedUnifiedChannelId = 'prayer_athan_channel_v3';
  static const String unifiedChannelId = 'prayer_athan_channel_v4';
  static const String _silentPrayerChannelId = 'prayer_silent_channel_v1';
  static const String _dawoodChannelId = 'dawood_channel';
  static const String _athanSound = 'athan_ogg';
  static const String _iosAthanSound = 'athan.aiff';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      final TimezoneInfo timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      // Fallback to default UTC to avoid crashing when timezone cannot be resolved.
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    await requestNotificationPermissions();

    if (Platform.isAndroid) {
      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            unifiedChannelId,
            'Prayer & Athan Notifications',
            description: 'All prayer notifications with Athan sound',
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(_athanSound),
            audioAttributesUsage: AudioAttributesUsage.alarm,
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _silentPrayerChannelId,
            'Prayer Notifications (Silent)',
            description: 'Prayer notifications without Athan sound',
            importance: Importance.defaultImportance,
            playSound: false,
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _dawoodChannelId,
            'Dawood Reminders',
            description: 'Supplications of Prophet Dawood (AS)',
            importance: Importance.defaultImportance,
          ),
        );

        await androidPlugin.deleteNotificationChannel(_legacyPrayerChannelId);
        await androidPlugin.deleteNotificationChannel(_legacyAthanChannelId);
        await androidPlugin
            .deleteNotificationChannel(_deprecatedPrayerChannelId);
        await androidPlugin
            .deleteNotificationChannel(_deprecatedAthanChannelId);
        await androidPlugin
            .deleteNotificationChannel(_deprecatedUnifiedChannelId);
      }
    }

    _initialized = true;
  }

  Future<void> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return;
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
      await androidPlugin.requestFullScreenIntentPermission();
      return;
    }

    if (Platform.isIOS) {
      final iosPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return;
    }

    if (Platform.isMacOS) {
      final macPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>();
      await macPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> requestAndroidPermissions() async {
    await requestNotificationPermissions();
  }

  Future<Map<String, bool?>> getAndroidStatus() async {
    if (!Platform.isAndroid) {
      return <String, bool?>{};
    }
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      return <String, bool?>{
        'notificationsEnabled': null,
        'canScheduleExact': null,
      };
    }
    final notificationsEnabled = await androidPlugin.areNotificationsEnabled();
    final canScheduleExact =
        await androidPlugin.canScheduleExactNotifications();
    return <String, bool?>{
      'notificationsEnabled': notificationsEnabled,
      'canScheduleExact': canScheduleExact,
    };
  }

  Future<Map<String, bool?>> getDarwinStatus() async {
    if (!(Platform.isIOS || Platform.isMacOS)) {
      return <String, bool?>{};
    }

    NotificationsEnabledOptions? status;
    if (Platform.isIOS) {
      final iosPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      status = await iosPlugin?.checkPermissions();
    } else if (Platform.isMacOS) {
      final macPlugin =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>();
      status = await macPlugin?.checkPermissions();
    }

    if (status == null) {
      return <String, bool?>{
        'enabled': null,
        'sound': null,
        'alert': null,
        'badge': null,
        'provisional': null,
      };
    }

    return <String, bool?>{
      'enabled': status.isEnabled,
      'sound': status.isSoundEnabled,
      'alert': status.isAlertEnabled,
      'badge': status.isBadgeEnabled,
      'provisional': status.isProvisionalEnabled,
    };
  }

  Future<Map<String, Map<String, Object?>>> getAndroidChannelStatus() async {
    if (!Platform.isAndroid) {
      return <String, Map<String, Object?>>{};
    }
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      return <String, Map<String, Object?>>{};
    }
    final channels = await androidPlugin.getNotificationChannels();
    if (channels == null || channels.isEmpty) {
      return <String, Map<String, Object?>>{};
    }
    final status = <String, Map<String, Object?>>{};
    for (final channel in channels) {
      if (channel.id == unifiedChannelId) {
        status[channel.id] = <String, Object?>{
          'id': channel.id,
          'importance': channel.importance.value,
          'playSound': channel.playSound,
          'sound': channel.sound?.toString(),
          'audioUsage': channel.audioAttributesUsage.value,
        };
      }
    }
    return status;
  }

  Future<void> showAthanNow({String? title, String? body}) async {
    if (!_initialized) await init();
    await flutterLocalNotificationsPlugin.show(
      9998,
      title ?? "الصلاة",
      body ?? "اختبار صوت الأذان / Athan test now",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          unifiedChannelId,
          'Prayer & Athan Notifications',
          channelDescription: 'All prayer notifications with Athan sound',
          importance: Importance.max,
          priority: Priority.max,
          sound: RawResourceAndroidNotificationSound(_athanSound),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          sound: _iosAthanSound,
          presentSound: true,
          presentBanner: true,
          presentList: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }

  Future<AndroidScheduleMode> _resolveAndroidScheduleMode() async {
    if (!Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final canExact = await androidPlugin?.canScheduleExactNotifications();
    if (canExact == true) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }
    return AndroidScheduleMode.inexact;
  }

  Future<void> schedulePrayer(int id, String title, String body, DateTime time,
      {bool playAthan = false}) async {
    if (!_initialized) await init();

    if (time.isBefore(DateTime.now())) return;

    final scheduleMode = await _resolveAndroidScheduleMode();
    final channelId = playAthan ? unifiedChannelId : _silentPrayerChannelId;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          playAthan
              ? 'Prayer & Athan Notifications'
              : 'Prayer Notifications (Silent)',
          channelDescription: playAthan
              ? 'All prayer notifications with Athan sound'
              : 'Prayer notifications without Athan sound',
          importance: playAthan ? Importance.max : Importance.defaultImportance,
          priority: playAthan ? Priority.max : Priority.defaultPriority,
          sound: playAthan
              ? const RawResourceAndroidNotificationSound(_athanSound)
              : null,
          playSound: playAthan,
          audioAttributesUsage: playAthan
              ? AudioAttributesUsage.alarm
              : AudioAttributesUsage.notification,
          category: playAthan
              ? AndroidNotificationCategory.alarm
              : AndroidNotificationCategory.reminder,
          fullScreenIntent: playAthan, // Wake up screen only for Athan
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          sound: playAthan ? _iosAthanSound : null,
          presentSound: playAthan,
          presentBanner: true,
          presentList: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: scheduleMode,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> scheduleDawoodReminder(
      int id, String title, String body, DateTime time) async {
    if (!_initialized) await init();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(time, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _dawoodChannelId,
          'Dawood Reminders',
          channelDescription: 'Supplications of Prophet Dawood (AS)',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          presentBanner: true,
          presentList: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
