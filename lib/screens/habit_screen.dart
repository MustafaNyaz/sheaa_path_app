import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final streak = appProvider.currentStreak;
    final tr = appProvider.tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('habit_tracker'), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Streak Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent.withValues(alpha: 0.2), AppColors.accent.withValues(alpha: 0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(tr('streak_title'), style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text(
                      "$streak",
                      style: GoogleFonts.cairo(fontSize: 60, fontWeight: FontWeight.bold, color: AppColors.accent, height: 1),
                    ),
                    Text(tr('streak_days'), style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Calendar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TableCalendar<dynamic>(
                  locale: appProvider.locale == 'ar' ? 'ar' : 'en_US',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: CalendarFormat.month,
                  rowHeight: 52,
                  daysOfWeekHeight: 30,
                  
                  // Fix Day Names (Show first letter)
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                    weekendStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    dowTextFormatter: (date, locale) {
                      final localeStr = locale.toString();
                      return localeStr.startsWith('ar') 
                        ? ['ح','ن','ث','ر','خ','ج','س'][date.weekday % 7]
                        : ['S','M','T','W','T','F','S'][date.weekday % 7];
                    },
                  ),

                  headerStyle: const HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.accent),
                    rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.accent),
                    headerPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  
                  calendarStyle: const CalendarStyle(
                    defaultTextStyle: TextStyle(color: Colors.white, fontSize: 14),
                    weekendTextStyle: TextStyle(color: Colors.white70, fontSize: 14),
                    outsideTextStyle: TextStyle(color: Colors.white24, fontSize: 12),
                    todayDecoration: BoxDecoration(
                      color: Colors.white10,
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  // This is the core fix: Using calendarBuilders to show all completed days
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      if (appProvider.isHabitCompleted(day)) {
                        return _buildCompletedDay(day);
                      }
                      return null;
                    },
                    todayBuilder: (context, day, focusedDay) {
                      if (appProvider.isHabitCompleted(day)) {
                        return _buildCompletedDay(day, isToday: true);
                      }
                      return null;
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      if (appProvider.isHabitCompleted(day)) {
                        return Opacity(opacity: 0.5, child: _buildCompletedDay(day));
                      }
                      return null;
                    },
                  ),
                  
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                    appProvider.toggleHabit(selectedDay);
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              Text(
                tr('click_to_log'),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedDay(DateTime day, {bool isToday = false}) {
    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: [
          BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Icon(Icons.check, color: Colors.black, size: 10),
        ],
      ),
    );
  }
}



