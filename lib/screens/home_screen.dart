import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:showcaseview/showcaseview.dart';
import 'dart:ui' as ui;

import 'settings_screen.dart';
import 'qiyam_mode_screen.dart';
import 'habit_screen.dart';
import 'qibla_screen.dart';
import 'athkar_screen.dart';
import 'names_of_allah_screen.dart';
import '../providers/app_provider.dart';
import '../models/prayer_times_model.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import '../utils/platform_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _habitKey = GlobalKey();
  final GlobalKey _countdownKey = GlobalKey();
  final GlobalKey _prayerCardsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTutorial();
    });
  }

  void _startTutorial() {
    final provider = context.read<AppProvider>();
    if (!provider.hasSeenTutorial) {
      ShowCaseWidget.of(context).startShowCase([
        _settingsKey,
        _habitKey,
        _countdownKey,
        _prayerCardsKey,
      ]);
      provider.updateTutorialSeen(true);
    }
  }

  void openSettings() {
    Navigator.push(context,
        MaterialPageRoute<void>(builder: (context) => const SettingsScreen()));
  }

  void changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      context.read<AppProvider>().calculatePrayerTimes(_selectedDate);
    });
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: AppColors.bg),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        context.read<AppProvider>().calculatePrayerTimes(_selectedDate);
      });
    }
  }

  String fmt(DateTime? dt, String locale) =>
      (dt == null) ? "--:--" : DateFormat('h:mm a', locale).format(dt);

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final prayerTimes = appProvider.prayerTimes;
    final hijriDate = HijriCalendar.fromDate(_selectedDate);
    final tr = appProvider.tr;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: true,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHero(appProvider, hijriDate, prayerTimes, tr),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildDateNavigator(appProvider.locale)
                      .animate()
                      .fadeIn(delay: 150.ms),
                  const SizedBox(height: 26),
                  Showcase(
                    key: _prayerCardsKey,
                    description: tr('qiyam_dashboard'),
                    child: prayerTimes != null
                        ? _buildNightPath(prayerTimes, appProvider)
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1, end: 0)
                        : const SizedBox(),
                  ),
                  const SizedBox(height: 32),
                  if (prayerTimes != null) ...[
                    _buildSectionTitle(tr('daily_prayers')),
                    const SizedBox(height: 14),
                    _buildDailyPrayerGrid(prayerTimes, appProvider),
                  ],
                  const SizedBox(height: 32),
                  _buildSectionTitle(tr('more_features')),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.6,
                    children: [
                      _buildFeatureCard(
                        tr('qibla_compass'),
                        Icons.explore_rounded,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const QiblaScreen())),
                      ),
                      _buildFeatureCard(
                        tr('names_of_allah'),
                        Icons.menu_book_rounded,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NamesOfAllahScreen())),
                      ),
                      _buildFeatureCard(
                        tr('athkar'),
                        Icons.auto_stories_rounded,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AthkarScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 10),
            )
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              child: Icon(icon, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(AppProvider appProvider, HijriCalendar hijriDate,
      PrayerTimesModel? prayerTimes, String Function(String) tr) {
    final gregorian = DateFormat('EEE, d MMM').format(_selectedDate);
    final methodName =
        appProvider.prayerService.getMethodName(appProvider.methodId);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgSoft, AppColors.surface, AppColors.bg],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('app_title'),
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hijriDate.toFormat("DDDD d MMMM yyyy"),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gregorian,
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Showcase(
                    key: _settingsKey,
                    description: tr('settings'),
                    child: _buildHeaderAction(
                      icon: Icons.settings_rounded,
                      onTap: openSettings,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Showcase(
                    key: _habitKey,
                    description: tr('habit_tracker'),
                    child: _buildHeaderAction(
                      icon: Icons.calendar_today_rounded,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (context) => const HabitScreen())),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded,
                    color: AppColors.accent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appProvider.locationName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  methodName,
                  style: const TextStyle(
                      color: AppColors.accentSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Showcase(
            key: _countdownKey,
            description: tr('countdown_qiyam'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: CountdownTimerWidget(
                  prayerTimes: prayerTimes, selectedDate: _selectedDate),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  tr('tasbih_adhkar'),
                  Icons.mosque_rounded,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (context) => const QiyamModeScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  tr('athkar'),
                  Icons.auto_stories_rounded,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (context) => const AthkarScreen())),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(
      {required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.accent),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildDateNavigator(String locale) {
    return Center(
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                    color: Colors.white54, size: 28),
                onPressed: () => changeDate(-1),
                tooltip: '',
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pickDate,
                  icon: const Icon(Icons.calendar_month_rounded,
                      color: AppColors.accent, size: 18),
                  label: Text(
                    DateFormat('EEE, d MMM').format(_selectedDate),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppColors.accent.withValues(alpha: 0.3)),
                    backgroundColor: AppColors.card,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded,
                    color: Colors.white54, size: 28),
                onPressed: () => changeDate(1),
                tooltip: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNightPath(PrayerTimesModel prayerTimes, AppProvider provider) {
    final tr = provider.tr;
    final locale = provider.locale;
    final wakeTime = prayerTimes.wakeTime;
    final isQiyamTime = wakeTime != null && DateTime.now().isAfter(wakeTime);
    final steps = [
      {
        'title': tr('prayer_1'),
        'time': fmt(prayerTimes.ishaTime, locale),
        'subtitle':
            "${tr('duration')}: ${getDuration(prayerTimes.ishaTime, prayerTimes.wakeTime, tr)}",
        'icon': Icons.bed_rounded,
        'color': AppColors.muted,
      },
      {
        'title': tr('prayer_2'),
        'time': fmt(prayerTimes.wakeTime, locale),
        'subtitle': "${tr('until')}: ${fmt(prayerTimes.stopTime, locale)}",
        'icon': Icons.star_rounded,
        'color': AppColors.accent,
      },
      {
        'title': tr('prayer_3'),
        'time': fmt(prayerTimes.stopTime, locale),
        'subtitle': "${tr('fajr')}: ${fmt(prayerTimes.fajrTime, locale)}",
        'icon': Icons.wb_twilight_rounded,
        'color': AppColors.info,
      },
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isMain = index == 1;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: step['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 64,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isMain
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isMain
                        ? AppColors.accent.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(step['icon'] as IconData,
                            color: step['color'] as Color, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            step['title'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            step['time'] as String,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step['subtitle'] as String,
                      style:
                          const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                    if (isMain) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isQiyamTime
                              ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const QiyamModeScreen()))
                              : () => setAlarm(prayerTimes.wakeTime, provider),
                          icon: Icon(
                            isQiyamTime
                                ? Icons.shield_moon_rounded
                                : Icons.alarm_add_rounded,
                            color: AppColors.bg,
                          ),
                          label: Text(
                            isQiyamTime
                                ? tr('start_qiyam_mode')
                                : tr('set_alarm'),
                            style: const TextStyle(
                                color: AppColors.bg,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            minimumSize: const Size(double.infinity, 48),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDailyPrayerGrid(
      PrayerTimesModel prayerTimes, AppProvider provider) {
    final tr = provider.tr;
    final locale = provider.locale;

    final items = [
      {
        'id': 'fajr',
        'title': tr('fajr'),
        'time': prayerTimes.fajrTime,
        'icon': Icons.wb_twilight_rounded
      },
      {
        'id': 'dhuhr',
        'title': tr('dhuhr'),
        'time': prayerTimes.dhuhrTime,
        'icon': Icons.wb_sunny_rounded
      },
      {
        'id': 'asr',
        'title': tr('asr'),
        'time': prayerTimes.asrTime,
        'icon': Icons.wb_sunny_outlined
      },
      {
        'id': 'maghrib',
        'title': tr('maghrib'),
        'time': prayerTimes.maghribTime,
        'icon': Icons.nights_stay_outlined
      },
      {
        'id': 'isha',
        'title': locale == 'ar' ? 'العشاء' : 'Isha',
        'time': prayerTimes.ishaTime,
        'icon': Icons.nights_stay_rounded
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 122,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final id = item['id'] as String;
        final isAthanOn = provider.isAthanEnabledFor(id);
        final time = item['time'] as DateTime?;

        return Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item['icon'] as IconData,
                      color: AppColors.accent, size: 18),
                  const Spacer(),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isAthanOn
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_outlined,
                      color: isAthanOn ? AppColors.accent : Colors.grey,
                      size: 18,
                    ),
                    onPressed: () => provider.toggleAthan(id, !isAthanOn),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  fmt(time, locale),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['title'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  String getDuration(
      DateTime? start, DateTime? end, String Function(String) tr) {
    if (start == null || end == null) return "";
    final diff = end.difference(start);
    return "${diff.inHours} ${tr('hours')} ${tr('or') == 'أو' ? 'و' : '&'} ${diff.inMinutes.remainder(60)} ${tr('minutes')}";
  }

  Future<void> setAlarm(DateTime? time, AppProvider provider) async {
    if (time == null) return;
    final tr = provider.tr;

    if (PlatformUtils.isIOS) {
      try {
        final ns = NotificationService();
        await ns.schedulePrayer(
          5001,
          tr('app_title'),
          '${tr('qiyam_time')}: ${fmt(time, provider.locale)}',
          time,
          playAthan: true,
        );
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(tr('alarm_set_success'))));
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  '${tr('alarm_set_fail')}\n${tr('qiyam_time')}: ${fmt(time, provider.locale)}')));
      }
      return;
    }

    if (!PlatformUtils.supportsAlarms) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${tr('alarm_set_fail')} (Mobile Only)")));
      return;
    }

    try {
      if (PlatformUtils.isAndroid) {
        final intent = AndroidIntent(
          action: 'android.intent.action.SET_ALARM',
          arguments: <String, dynamic>{
            'android.intent.extra.alarm.HOUR': time.hour,
            'android.intent.extra.alarm.MINUTES': time.minute,
            'android.intent.extra.alarm.MESSAGE': tr('app_title'),
            'android.intent.extra.alarm.SKIP_UI': true,
          },
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intent.launch();
        if (mounted)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(tr('alarm_set_success'))));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${tr('alarm_set_fail')}\n${tr('qiyam_time')}: ${fmt(time, provider.locale)}')));
    }
  }
}

class CountdownTimerWidget extends StatefulWidget {
  final PrayerTimesModel? prayerTimes;
  final DateTime selectedDate;

  const CountdownTimerWidget(
      {super.key, required this.prayerTimes, required this.selectedDate});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Stream<DateTime> _timerStream;

  @override
  void initState() {
    super.initState();
    _timerStream =
        Stream.periodic(const Duration(seconds: 1), (i) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.read<AppProvider>().tr;
    return StreamBuilder<DateTime>(
      stream: _timerStream,
      builder: (context, snapshot) {
        final prayerTimes = widget.prayerTimes;
        if (prayerTimes?.wakeTime == null) return const SizedBox();

        final now = DateTime.now();
        final today = DateTime.now();
        final isSelectedToday = widget.selectedDate.year == today.year &&
            widget.selectedDate.month == today.month &&
            widget.selectedDate.day == today.day;

        if (!isSelectedToday) {
          return Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10)),
              child: Text(tr('selected_night'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          );
        }

        String nextName = "";
        Duration diff = Duration.zero;
        Color statusColor = AppColors.accent;

        if (now.isBefore(prayerTimes!.wakeTime!)) {
          nextName = tr('countdown_qiyam');
          diff = prayerTimes.wakeTime!.difference(now);
        } else if (now.isBefore(prayerTimes.stopTime!)) {
          nextName = tr('countdown_stop');
          diff = prayerTimes.stopTime!.difference(now);
          statusColor = AppColors.danger;
        } else if (now.isBefore(prayerTimes.fajrTime!)) {
          nextName = tr('countdown_fajr');
          diff = prayerTimes.fajrTime!.difference(now);
          statusColor = AppColors.info;
        } else {
          return Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.grey.withValues(alpha: 0.3))),
              child: Text(tr('qiyam_ended'),
                  style: const TextStyle(color: Colors.grey)),
            ),
          );
        }

        final remStr = tr('or') == 'أو' ? 'باقي على' : 'Remaining for';

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$remStr $nextName".toUpperCase(),
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${diff.inHours}:${(diff.inMinutes % 60).toString().padLeft(2, '0')}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}",
                style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w200,
                    fontSize: 52,
                    letterSpacing: -1,
                    height: 1,
                    shadows: [
                      Shadow(
                        color: statusColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                      ),
                      Shadow(
                        color: statusColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                      )
                    ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
