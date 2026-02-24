import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/dnd_service.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';

import '../providers/app_provider.dart';
import '../utils/app_colors.dart';
import '../utils/platform_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _cityController = TextEditingController();
  static const int _athanTestNotificationId = 9999;

  @override
  void initState() {
    super.initState();
    // Check permission on enter to keep UI in sync
    _checkDndPermission();
  }

  Future<void> _checkDndPermission() async {
    final provider = context.read<AppProvider>();
    if (provider.isDndEnabled) {
      final granted = await DndService.isPermissionGranted();
      if (!granted) {
        unawaited(provider.toggleDndPreference(false));
      }
    }
  }

  Future<void> _checkPermissions() async {
    if (PlatformUtils.isIOS) {
      final notifStatus = await Permission.notification.status;
      if (notifStatus.isDenied) {
        await Permission.notification.request();
      }

      final locationStatus = await Permission.locationWhenInUse.status;
      if (locationStatus.isDenied) {
        await Permission.locationWhenInUse.request();
      }

      await NotificationService().requestNotificationPermissions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('iOS permissions checked: notifications + location.')),
        );
      }
      return;
    }

    if (!PlatformUtils.isAndroid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Permission diagnostics are available on mobile devices.')),
        );
      }
      return;
    }

    final statusBattery = await Permission.ignoreBatteryOptimizations.status;
    if (!statusBattery.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    final statusAlarm = await Permission.scheduleExactAlarm.status;
    if (statusAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    final statusNotif = await Permission.notification.status;
    if (statusNotif.isDenied) {
      await Permission.notification.request();
    }

    await NotificationService().requestNotificationPermissions();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppProvider>().tr('reset_done'))),
      );
    }
  }

  String _permissionLabel(PermissionStatus status) {
    if (status.isGranted) return 'granted';
    if (status.isDenied) return 'denied';
    if (status.isPermanentlyDenied) return 'blocked';
    if (status.isRestricted) return 'restricted';
    if (status.isLimited) return 'limited';
    return status.toString();
  }

  String _boolLabel(bool? value) {
    if (value == null) return 'unknown';
    return value ? 'yes' : 'no';
  }

  String _channelLabel(Map<String, Object?>? info) {
    if (info == null) return 'missing';
    final importance = info['importance'];
    final playSound = info['playSound'];
    final audioUsage = info['audioUsage'];
    return 'importance=$importance sound=$playSound usage=$audioUsage';
  }

  Future<void> _openAthanChannelSettings() async {
    if (!PlatformUtils.isAndroid) {
      await openAppSettings();
      return;
    }
    try {
      final info = await PackageInfo.fromPlatform();
      final intent = AndroidIntent(
        action: 'android.settings.CHANNEL_NOTIFICATION_SETTINGS',
        arguments: <String, dynamic>{
          'android.provider.extra.APP_PACKAGE': info.packageName,
          'android.provider.extra.CHANNEL_ID':
              NotificationService.unifiedChannelId,
        },
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (_) {
      await openAppSettings();
    }
  }

  Future<void> _testAthanNotification() async {
    final ns = NotificationService();
    await ns.requestNotificationPermissions();
    await ns.init();

    final androidStatus = await ns.getAndroidStatus();
    final darwinStatus = await ns.getDarwinStatus();
    final channelStatus = await ns.getAndroidChannelStatus();

    final statusNotif = await Permission.notification.status;
    PermissionStatus? statusBattery;
    PermissionStatus? statusAlarm;
    if (androidStatus.isNotEmpty) {
      statusBattery = await Permission.ignoreBatteryOptimizations.status;
      statusAlarm = await Permission.scheduleExactAlarm.status;
    }

    final athanChannel = channelStatus[NotificationService.unifiedChannelId];
    final notificationsEnabled = androidStatus.isNotEmpty
        ? androidStatus['notificationsEnabled']
        : darwinStatus['enabled'];
    final canExact =
        androidStatus.isEmpty || androidStatus['canScheduleExact'] == true;
    final channelSilent = androidStatus.isNotEmpty &&
        athanChannel != null &&
        athanChannel['playSound'] == false;

    final when = DateTime.now().add(const Duration(seconds: 10));
    await ns.schedulePrayer(
      _athanTestNotificationId,
      "الصلاة",
      "اختبار صوت الأذان / Athan test",
      when,
      playAthan: true,
    );

    if (!mounted) return;

    final appProvider = context.read<AppProvider>();
    final shouldFallbackAudio =
        notificationsEnabled == false || channelSilent || !canExact;
    if (shouldFallbackAudio) {
      unawaited(Future.delayed(const Duration(seconds: 10), () async {
        if (!mounted) return;
        await ns.showAthanNow(
          title: "الصلاة",
          body: "اختبار صوت الأذان / Athan test now",
        );
        if (!appProvider.isPlayingAthan) {
          await appProvider.playAthan();
        }
      }));
    }

    bool playedFallbackAudio = false;
    final notifDenied = !statusNotif.isGranted;
    if (!shouldFallbackAudio &&
        (notificationsEnabled == false || notifDenied)) {
      if (!appProvider.isPlayingAthan) {
        await appProvider.playAthan();
        playedFallbackAudio = true;
      }
    }

    final debugLines = <String>[
      'Athan test scheduled in 10 seconds.',
    ];
    if (androidStatus.isNotEmpty) {
      debugLines.addAll(<String>[
        'Notification perm: ${_permissionLabel(statusNotif)} | Enabled: ${_boolLabel(androidStatus['notificationsEnabled'])}',
        'Exact alarm: ${_permissionLabel(statusAlarm!)} | Can exact: ${_boolLabel(androidStatus['canScheduleExact'])}',
        'Battery optimization: ${_permissionLabel(statusBattery!)}',
        'Athan channel: ${_channelLabel(athanChannel)}',
      ]);
    }
    if (darwinStatus.isNotEmpty) {
      debugLines.add(
        'iOS notifications: enabled=${_boolLabel(darwinStatus['enabled'])} sound=${_boolLabel(darwinStatus['sound'])} alert=${_boolLabel(darwinStatus['alert'])}',
      );
    }
    if (androidStatus.isNotEmpty && !canExact) {
      debugLines.add('Exact alarms off: test may be delayed.');
    }
    if (shouldFallbackAudio) {
      debugLines.add('Fallback: in-app Athan will play in 10 seconds.');
    }
    if (playedFallbackAudio) {
      debugLines.add('Fallback: played in-app Athan audio.');
    }

    final debugMessage = debugLines.join('\n');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(debugMessage),
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: PlatformUtils.isAndroid ? 'Channel' : 'Settings',
          onPressed: _openAthanChannelSettings,
        ),
      ),
    );
  }

  void _searchCity() async {
    final provider = context.read<AppProvider>();
    final query = _cityController.text.trim();
    if (query.isEmpty) return;

    final result = await provider.searchCity(query);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    if (result.startsWith('ØªÙ…') || result.startsWith('Location')) {
      Navigator.pop(context);
    }
  }

  void _getLocation() async {
    final provider = context.read<AppProvider>();
    final result = await provider.updateLocationWithGPS();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
  }

  void _showEditNameDialog(BuildContext context) {
    final provider = context.read<AppProvider>();
    final tr = provider.tr;
    final controller =
        TextEditingController(text: provider.currentUser?.displayName);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(tr('profile'),
            style: const TextStyle(color: AppColors.accent)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: tr('locale') == 'ar' ? 'Ø§Ù„Ø§Ø³Ù…' : 'Name',
            labelStyle: const TextStyle(color: AppColors.accent),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(tr('close'))),
          TextButton(
            onPressed: () async {
              await provider.updateDisplayName(controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Ø­ÙØ¸ / Save",
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  Future<void> _showAbout() async {
    final info = await PackageInfo.fromPlatform();
    final tr = context.read<AppProvider>().tr;
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(tr('about_app'),
            style: const TextStyle(color: AppColors.accent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.accent,
              child: Icon(Icons.code, color: Colors.black),
            ),
            const SizedBox(height: 15),
            Text("${tr('developer')}: Mustafa Nyaz",
                style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 5),
            Text("${tr('version')}: ${info.version}",
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            Text(
              tr('about_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('close'),
                style: const TextStyle(color: AppColors.accent)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, child) {
      final user = appProvider.currentUser;
      final tr = appProvider.tr;

      return Scaffold(
        appBar: AppBar(
          title:
              Text(tr('settings'), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // User Account Section
              Text(tr('profile'),
                  style: const TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          backgroundColor: AppColors.bg,
                          child: user?.photoURL == null
                              ? const Icon(Icons.person,
                                  size: 35, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user?.displayName ?? tr('guest'),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (user != null)
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          size: 16, color: AppColors.accent),
                                      onPressed: () =>
                                          _showEditNameDialog(context),
                                    ),
                                ],
                              ),
                              Text(
                                user?.email ??
                                    user?.phoneNumber ??
                                    tr('login_to_save'),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: user == null
                          ? () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (context) => const LoginScreen()))
                          : appProvider.signOut,
                      icon: Icon(user == null ? Icons.login : Icons.logout,
                          size: 18),
                      label: Text(
                          user == null ? tr('login_page_title') : tr('logout')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user == null
                            ? AppColors.accent
                            : Colors.redAccent.withValues(alpha: 0.2),
                        foregroundColor:
                            user == null ? Colors.black : Colors.redAccent,
                        minimumSize: const Size(double.infinity, 45),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Preferences Section
              Text(tr('preferences'),
                  style: const TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(tr('language'),
                          style: const TextStyle(color: Colors.white)),
                      trailing: DropdownButton<String>(
                        value: appProvider.locale,
                        dropdownColor: AppColors.surface,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                              value: 'ar',
                              child: Text("Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©",
                                  style: TextStyle(color: AppColors.accent))),
                          DropdownMenuItem(
                              value: 'en',
                              child: Text("English",
                                  style: TextStyle(color: AppColors.accent))),
                        ],
                        onChanged: (val) {
                          if (val != null) appProvider.updateLocale(val);
                        },
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    SwitchListTile(
                      title: Text(tr('daily_reminders'),
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(tr('daily_reminders_desc'),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      value: appProvider.dailyReminders,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) => appProvider.toggleDailyReminders(val),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    SwitchListTile(
                      title: Text(tr('dawood_reminders'),
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(tr('dawood_reminders_desc'),
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      value: appProvider.dawoodRemindersEnabled,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) =>
                          appProvider.toggleDawoodReminders(val),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(tr('font_size'),
                                  style: const TextStyle(color: Colors.white)),
                              Text(appProvider.fontScale.toStringAsFixed(1),
                                  style:
                                      const TextStyle(color: AppColors.accent)),
                            ],
                          ),
                          Slider(
                            value: appProvider.fontScale,
                            min: 0.8,
                            max: 1.4,
                            divisions: 6,
                            activeColor: AppColors.accent,
                            onChanged: (val) =>
                                appProvider.updateFontScale(val),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    ListTile(
                      leading:
                          const Icon(Icons.restore, color: Colors.redAccent),
                      title: Text(tr('reset_defaults'),
                          style: const TextStyle(color: Colors.redAccent)),
                      onTap: () async {
                        await appProvider.resetSettings();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(tr('reset_done'))));
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // System Optimizations Section (NEW)
              Text(tr('system_optimizations'),
                  style: const TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.speed_rounded,
                      color: Colors.greenAccent),
                  title: Text(tr('check_permissions'),
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(
                    PlatformUtils.isIOS
                        ? 'Check iOS notification and location permissions.'
                        : tr('battery_desc'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: _checkPermissions,
                ),
              ),

              const SizedBox(height: 30),

              // DND Section
              if (PlatformUtils.supportsDnd) ...[
                Text(tr('dnd_mode'),
                    style: const TextStyle(
                        color: AppColors.accent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SwitchListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  title: Text(tr('dnd_desc'),
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text(tr('dnd_subdesc'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  value: appProvider.isDndEnabled,
                  activeThumbColor: AppColors.accent,
                  onChanged: (val) => appProvider.toggleDndPreference(val),
                ),
                const SizedBox(height: 30),
              ],

              // Location Section
              Text(tr('location'),
                  style: const TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              ListTile(
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                leading: Icon(Icons.my_location,
                    color: appProvider.isLoading
                        ? AppColors.accent
                        : Colors.white),
                title: Text(tr('gps_fetch'),
                    style: const TextStyle(color: Colors.white)),
                trailing: appProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.accent))
                    : const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.grey),
                onTap: appProvider.isLoading ? null : _getLocation,
              ),

              const SizedBox(height: 15),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: tr('manual_search'),
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: Colors.grey),
                        ),
                        onSubmitted: (_) => _searchCity(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: AppColors.accent),
                      onPressed: _searchCity,
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Calculation Method Section
              Text(tr('calculation_method'),
                  style: const TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: appProvider.prayerService
                      .getMethodsBySect(appProvider.sect)
                      .map((methodId) {
                    return _buildRadioTile(
                        appProvider.prayerService.getMethodName(methodId),
                        methodId);
                  }).toList(),
                ),
              ),

              const SizedBox(height: 30),

              // Athan Section
              const Text("Ø§Ù„Ø£Ø°Ø§Ù† / Athan",
                  style: TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                leading: Icon(
                  appProvider.isPlayingAthan
                      ? Icons.stop_circle_rounded
                      : Icons.play_circle_fill_rounded,
                  color: appProvider.isPlayingAthan
                      ? Colors.redAccent
                      : AppColors.accent,
                  size: 30,
                ),
                title: Text(
                    appProvider.isPlayingAthan
                        ? "Ø¥ÙŠÙ‚Ø§Ù Ø§Ù„ØµÙˆØª / Stop Audio"
                        : "ØªØ¬Ø±Ø¨Ø© ØµÙˆØª Ø§Ù„Ø£Ø°Ø§Ù† / Test Athan Sound",
                    style: const TextStyle(color: Colors.white)),
                subtitle: const Text(
                  "Plays inside the app (fallback if notifications are silent)",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                onTap: () => appProvider.playAthan(),
              ),

              const SizedBox(height: 10),
              ListTile(
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.notifications_active_rounded,
                    color: AppColors.accent),
                title: const Text(
                    "Ø§Ø®ØªØ¨Ø§Ø± Ø¥Ø´Ø¹Ø§Ø± Ø§Ù„Ø£Ø°Ø§Ù† / Test Athan Notification",
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text(
                    "Sends in 10 seconds (check channel settings if silent)",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: _testAthanNotification,
              ),

              const SizedBox(height: 30),

              // About Section
              ListTile(
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                leading:
                    const Icon(Icons.info_outline, color: AppColors.accent),
                title: Text(tr('about_app'),
                    style: const TextStyle(color: Colors.white)),
                onTap: () async => await _showAbout(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRadioTile(String title, String value) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: context.read<AppProvider>().methodId,
      activeColor: AppColors.accent,
      onChanged: (val) {
        if (val != null) context.read<AppProvider>().updateMethod(val);
      },
    );
  }
}
