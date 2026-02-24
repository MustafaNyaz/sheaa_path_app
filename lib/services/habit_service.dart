import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitService {
  final Box<bool> _box = Hive.box<bool>('habits');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getKey(DateTime date) {
    final utc = DateTime.utc(date.year, date.month, date.day);
    return "${utc.year}-${utc.month}-${utc.day}";
  }

  bool isDayCompleted(DateTime date) {
    return _box.get(_getKey(date), defaultValue: false) ?? false;
  }

  Future<void> toggleDay(DateTime date) async {
    final key = _getKey(date);
    final current = isDayCompleted(date);
    final newValue = !current;
    
    // 1. Update Local (Hive) - Immediate UI feedback
    await _box.put(key, newValue);

    // 2. Update Cloud (Firestore) - Only if logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Optimized: Background write, non-blocking
        _firestore
            .collection('users')
            .doc(user.uid)
            .collection('habits')
            .doc(key)
            .set({
              'completed': newValue, 
              'last_updated': FieldValue.serverTimestamp()
            }, SetOptions(merge: true));
      } catch (e) {
        // Silent fail for cloud, local is source of truth until next sync
      }
    }
  }

  Future<void> syncWithCloud() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .get(const GetOptions(source: Source.serverAndCache));

      // Merge Cloud to Local
      for (var doc in snapshot.docs) {
        final key = doc.id;
        final value = doc.data()['completed'] as bool? ?? false;
        if (value != _box.get(key)) {
          await _box.put(key, value);
        }
      }
    } catch (e) {
      // Handle sync error gracefully
    }
  }

  Future<void> clearLocal() async {
    await _box.clear();
  }

  int getStreak() {
    int streak = 0;
    final now = DateTime.now();
    DateTime date = DateTime.utc(now.year, now.month, now.day);
    
    // Check today, if not done check yesterday to start streak
    if (!isDayCompleted(date)) {
      date = date.subtract(const Duration(days: 1));
    }

    // Safety break at 10 years
    while (isDayCompleted(date) && streak < 3650) {
      streak++;
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }
}