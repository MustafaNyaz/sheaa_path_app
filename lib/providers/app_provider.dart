import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/notification_service.dart';
import 'dart:math';
import 'dart:async'; // For unawaited

import '../services/prayer_service.dart';
import '../services/habit_service.dart';
import '../services/dnd_service.dart';
import '../models/prayer_times_model.dart';
import '../utils/localization.dart';
import '../utils/platform_utils.dart';

class AppProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final PrayerService prayerService = PrayerService();
  final HabitService habitService = HabitService();
  final GoogleSignIn? _googleSignIn;
  final FirebaseAuth? _auth;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final bool _notificationsEnabled;

  // State
  late double _lat;
  late double _lng;
  late String _locationName;
  late String _methodId;
  late String _sect; // 'sunni' or 'shia'
  PrayerTimesModel? _prayerTimes;
  bool _isLoading = false;
  int _currentStreak = 0;
  bool _isDndEnabled = false;
  double _fontScale = 1.0;
  bool _dailyReminders = true;
  bool _hasSeenTutorial = false;
  String _locale = 'ar';
  User? _currentUser;

  // Athan Settings
  final Map<String, bool> _athanSettings = {
    'fajr': false,
    'dhuhr': false,
    'asr': false,
    'maghrib': false,
    'isha': false,
  };
  bool _dawoodRemindersEnabled = false;

  // Localization
  String tr(String key) => AppLocalizations(_locale).translate(key);

  // Getters
  double get lat => _lat;
  double get lng => _lng;
  String get locationName => _locationName;
  String get methodId => _methodId;
  String get sect => _sect;
  PrayerTimesModel? get prayerTimes => _prayerTimes;
  bool get isLoading => _isLoading;
  int get currentStreak => _currentStreak;
  bool get isDndEnabled => _isDndEnabled;
  double get fontScale => _fontScale;
  bool get dailyReminders => _dailyReminders;
  bool get hasSeenTutorial => _hasSeenTutorial;
  String get locale => _locale;
  User? get currentUser => _currentUser;

  bool isAthanEnabledFor(String prayer) => _athanSettings[prayer] ?? false;
  bool get dawoodRemindersEnabled => _dawoodRemindersEnabled;

  AppProvider(
    this.prefs, {
    bool enableAuth = true,
    bool enableNotifications = true,
    GoogleSignIn? googleSignIn,
    FirebaseAuth? auth,
  })  : _googleSignIn = enableAuth
            ? (googleSignIn ??
                GoogleSignIn(
                  serverClientId:
                      '966220959898-78sm1j31c4fd8pldo8vv76c54lcrbsdq.apps.googleusercontent.com',
                ))
            : null,
        _auth = enableAuth ? (auth ?? FirebaseAuth.instance) : null,
        _notificationsEnabled = enableNotifications {
    _loadSettings();
    if (enableAuth) {
      _initAuth();
    }
  }

  Future<void> _initAuth() async {
    final auth = _auth;
    if (auth == null) return;
    auth.authStateChanges().listen((user) async {
      _currentUser = user;
      if (user != null) {
        // Upon login, pull cloud data.
        await habitService.syncWithCloud();
        _currentStreak = habitService.getStreak();
      }
      notifyListeners();
    });
  }

  void _loadSettings() {
    _sect = prefs.getString('sect') ?? 'shia';
    _methodId = prefs.getString('methodId') ?? 'najaf';
    if (_sect != 'shia') {
      _sect = 'shia';
      prefs.setString('sect', 'shia');
    }
    final allowedMethods = prayerService.getMethodsBySect('shia');
    if (!allowedMethods.contains(_methodId)) {
      _methodId = 'najaf';
      prefs.setString('methodId', _methodId);
    }
    _lat = prefs.getDouble('lat') ?? 21.4225;
    _lng = prefs.getDouble('lng') ?? 39.8262;
    _locationName = prefs.getString('locationName') ?? "مكة المكرمة (افتراضي)";
    _isDndEnabled = prefs.getBool('isDndEnabled') ?? false;
    _fontScale = prefs.getDouble('font_scale') ?? 1.0;
    _dailyReminders = prefs.getBool('daily_reminders_enabled') ?? true;
    _hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;
    _locale = prefs.getString('locale') ?? 'ar';
    _dawoodRemindersEnabled = prefs.getBool('dawoodRemindersEnabled') ?? false;

    // Load individual athan settings
    for (var key in _athanSettings.keys) {
      _athanSettings[key] = prefs.getBool('athan_$key') ?? false;
    }

    HijriCalendar.setLocal(_locale);

    _prayerTimes =
        prayerService.calculateTimes(_lat, _lng, _methodId, DateTime.now());
    _currentStreak = habitService.getStreak();

    if (_notificationsEnabled) {
      // Initialize Notification Service
      unawaited(NotificationService().init());
    }

    if (prefs.getDouble('lat') == null) {
      Future.microtask(() => updateLocationWithGPS());
    }

    if (_notificationsEnabled) {
      unawaited(_scheduleNotifications());
    }
  }

  Future<void> updateSect(String newSect) async {
    _sect = 'shia';
    await prefs.setString('sect', 'shia');

    // Auto-switch method based on sect
    final methods = prayerService.getMethodsBySect(_sect);
    if (!methods.contains(_methodId)) {
      _methodId = 'najaf'; // Default to Najaf for Shia
      await prefs.setString('methodId', _methodId);
    }

    calculatePrayerTimes(DateTime.now());
  }

  // Athan Playback State
  bool _isPlayingAthan = false;
  bool get isPlayingAthan => _isPlayingAthan;

  Future<void> playAthan() async {
    try {
      if (_isPlayingAthan) {
        await _audioPlayer.stop();
        _isPlayingAthan = false;
        notifyListeners();
        return;
      }

      await _audioPlayer.setAudioContext(
        const AudioContext(
          android: AudioContextAndroid(
            usageType: AndroidUsageType.alarm,
            contentType: AndroidContentType.speech,
          ),
        ),
      );

      // Optimize for voice/speech
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(1.0);

      // Listen for completion
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlayingAthan = false;
        notifyListeners();
      });

      await _audioPlayer.play(AssetSource('audio/athan.mp3'));
      _isPlayingAthan = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Athan Error: $e");
      _isPlayingAthan = false;
      notifyListeners();
    }
  }

  Future<void> updateLocale(String langCode) async {
    _locale = langCode;
    await prefs.setString('locale', langCode);
    HijriCalendar.setLocal(langCode);
    notifyListeners();
  }

  Future<void> updateTutorialSeen(bool value) async {
    _hasSeenTutorial = value;
    await prefs.setBool('hasSeenTutorial', value);
    notifyListeners();
  }

  Future<void> toggleAthan(String prayer, bool value) async {
    _athanSettings[prayer] = value;
    await prefs.setBool('athan_$prayer', value);
    if (value && _notificationsEnabled) {
      await NotificationService().requestAndroidPermissions();
    }
    unawaited(_scheduleNotifications());
    notifyListeners();
  }

  Future<void> toggleDawoodReminders(bool value) async {
    _dawoodRemindersEnabled = value;
    await prefs.setBool('dawoodRemindersEnabled', value);
    if (value && _notificationsEnabled) {
      await NotificationService().requestAndroidPermissions();
    }
    unawaited(_scheduleNotifications());
    notifyListeners();
  }

  Future<void> _scheduleNotifications() async {
    if (!_notificationsEnabled) return;
    final ns = NotificationService();
    await ns.cancelAll(); // Clear old to reschedule

    final now = DateTime.now();
    final todayPrayerTimes =
        prayerService.calculateTimes(_lat, _lng, _methodId, now);

    // Calculate tomorrow's times for fallback
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowPrayerTimes =
        prayerService.calculateTimes(_lat, _lng, _methodId, tomorrow);

    // Schedule Prayers
    final prayersToday = {
      'fajr': todayPrayerTimes.fajrTime,
      'dhuhr': todayPrayerTimes.dhuhrTime,
      'asr': todayPrayerTimes.asrTime,
      'maghrib': todayPrayerTimes.maghribTime,
      'isha': todayPrayerTimes.ishaTime,
    };

    final prayersTomorrow = {
      'fajr': tomorrowPrayerTimes.fajrTime,
      'dhuhr': tomorrowPrayerTimes.dhuhrTime,
      'asr': tomorrowPrayerTimes.asrTime,
      'maghrib': tomorrowPrayerTimes.maghribTime,
      'isha': tomorrowPrayerTimes.ishaTime,
    };

    int id = 100;
    prayersToday.forEach((name, time) {
      if (time != null) {
        DateTime scheduledTime = time;

        // If today's time has passed, use tomorrow's time
        if (scheduledTime.isBefore(now)) {
          if (prayersTomorrow[name] != null) {
            scheduledTime = prayersTomorrow[name]!;
          }
        }

        // Only schedule if we have a valid future time
        if (scheduledTime.isAfter(now)) {
          final bool playSound = _athanSettings[name] ?? false;
          const String title = "الصلاة";
          final String body = "حان الآن وقت صلاة ${tr(name)}";
          ns.schedulePrayer(id++, title, body, scheduledTime,
              playAthan: playSound);
        }
      }
    });

    // Schedule Dawood Reminders (Random times if enabled)
    if (_dawoodRemindersEnabled) {
      _scheduleDawoodDuas(ns);
    }
  }

  void _scheduleDawoodDuas(NotificationService ns) {
    final duas = [
      "اللَّهُمَّ إِنِّي أَسْأَلُكَ حُبَّكَ، وَحُبَّ مَنْ يُحِبُّكَ...",
      "اللَّهُمَّ لَكَ الْحَمْدُ دَائِماً مَعَ دَوَامِكَ...",
      "اللَّهُمَّ إِنِّي أَسْأَلُكَ رَحْمَةً مِنْ عِنْدِكَ تَهْدِي بِهَا قَلْبِي...",
      "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ مَالٍ يَكُونُ عَلَيَّ فِتْنَةً...",
      "رَبِّ اغْفِرْ لِي وَهَبْ لِي مُلْكًا لَا يَنْبَغِي لِأَحَدٍ مِنْ بَعْدِي...",
      "أَنِّي مَسَّنِيَ الضُّرُّ وَأَنْتَ أَرْحَمُ الرَّاحِمِينَ"
    ];

    final random = Random();
    final now = DateTime.now();

    // Schedule 2 reminders for today/tomorrow
    for (int i = 0; i < 2; i++) {
      // Pick random time between 8am and 8pm
      final int hour = 8 + random.nextInt(12);
      final int minute = random.nextInt(60);
      DateTime scheduledTime =
          DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledTime.isBefore(now))
        scheduledTime = scheduledTime.add(const Duration(days: 1));

      final String dua = duas[random.nextInt(duas.length)];
      ns.scheduleDawoodReminder(
          200 + i, "دعاء من مزامير داوود", dua, scheduledTime);
    }
  }

  // Auth Methods
  Future<String?> signIn({bool isRegistering = false}) async {
    try {
      final googleSignIn = _googleSignIn;
      final auth = _auth;
      if (googleSignIn == null || auth == null) {
        return "Auth unavailable";
      }
      // Ensure clean state
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return "تم إلغاء العملية / Canceled";

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: null, idToken: googleAuth.idToken);

      await auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return "Auth Error: ${e.message}";
    } catch (error) {
      return "Error: $error";
    }
  }

  Future<String?> signUpWithEmail(
      String email, String password, String name) async {
    try {
      final auth = _auth;
      if (auth == null) return "Auth unavailable";
      final credential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
        _currentUser = auth.currentUser;
        notifyListeners();
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final auth = _auth;
      if (auth == null) return "Auth unavailable";
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateDisplayName(String name) async {
    try {
      final auth = _auth;
      if (auth == null) return "Auth unavailable";
      if (_currentUser != null) {
        await _currentUser!.updateDisplayName(name);
        await _currentUser!.reload();
        _currentUser = auth.currentUser;
        notifyListeners();
        return null;
      }
      return "User not logged in";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    final googleSignIn = _googleSignIn;
    final auth = _auth;
    if (googleSignIn != null) {
      await googleSignIn.signOut();
    }
    if (auth != null) {
      await auth.signOut();
    }
    await habitService.clearLocal();
    _currentStreak = 0;
    notifyListeners();
  }

  // DND & Logic
  Future<void> setQiyamMode(bool enabled) async {
    if (!_isDndEnabled) return;
    if (enabled) {
      await DndService.enableDnd();
    } else {
      await DndService.disableDnd();
    }
  }

  Future<void> toggleDndPreference(bool value) async {
    if (value) {
      final granted = await DndService.isPermissionGranted();
      if (!granted) {
        await DndService.gotoPolicySettings();
        _isDndEnabled = false;
        notifyListeners();
        return;
      }
    }
    _isDndEnabled = value;
    await prefs.setBool('isDndEnabled', value);
    if (!value) await DndService.disableDnd();
    notifyListeners();
  }

  Future<void> updateFontScale(double value) async {
    _fontScale = value;
    await prefs.setDouble('font_scale', value);
    notifyListeners();
  }

  Future<void> toggleDailyReminders(bool value) async {
    _dailyReminders = value;
    await prefs.setBool('daily_reminders_enabled', value);
    notifyListeners();
  }

  bool isHabitCompleted(DateTime date) => habitService.isDayCompleted(date);

  Future<void> toggleHabit(DateTime date) async {
    await habitService.toggleDay(date);
    _currentStreak = habitService.getStreak();
    notifyListeners();
  }

  void calculatePrayerTimes(DateTime date) {
    _prayerTimes = prayerService.calculateTimes(_lat, _lng, _methodId, date);
    unawaited(_scheduleNotifications());
    notifyListeners();
  }

  Future<void> updateMethod(String newMethod) async {
    _methodId = newMethod;
    await prefs.setString('methodId', newMethod);
    calculatePrayerTimes(DateTime.now());
  }

  Future<void> updateLocation(
      double newLat, double newLng, String newName) async {
    _lat = newLat;
    _lng = newLng;
    _locationName = newName;
    await prefs.setDouble('lat', newLat);
    await prefs.setDouble('lng', newLng);
    await prefs.setString('locationName', newName);
    calculatePrayerTimes(DateTime.now());
  }

  Future<String> updateLocationWithGPS() async {
    _isLoading = true;
    notifyListeners();
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw 'GPS Disabled';
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'Permission Denied';
      }

      Position? position;
      final LocationSettings highAccuracySettings = PlatformUtils.isAndroid
          ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 15),
            )
          : const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 15),
            );
      final LocationSettings lowAccuracySettings = PlatformUtils.isAndroid
          ? AndroidSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 20),
            )
          : const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 20),
            );
      try {
        position = await Geolocator.getLastKnownPosition();
        if (position != null) {
          // If cached position is older than 5 minutes, ignore it
          final age = DateTime.now().difference(position.timestamp);
          if (age.inMinutes > 5) position = null;
        }
      } catch (_) {} // Ignore last known errors

      if (position == null) {
        try {
          // Try high accuracy first
          position = await Geolocator.getCurrentPosition(
            locationSettings: highAccuracySettings,
          );
        } catch (_) {
          // Fallback to low accuracy
          position = await Geolocator.getCurrentPosition(
            locationSettings: lowAccuracySettings,
          );
        }
      }

      String cityName = "My Location";
      try {
        final List<Placemark> p = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (p.isNotEmpty)
          cityName =
              p.first.locality ?? p.first.administrativeArea ?? "My Location";
      } catch (_) {}

      await updateLocation(position.latitude, position.longitude, cityName);
      return "Updated: $cityName";
    } catch (e) {
      return "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetSettings() async {
    _fontScale = 1.0;
    _dailyReminders = true;
    _methodId = 'najaf';
    _sect = 'shia';
    _isDndEnabled = false;

    await prefs.setDouble('font_scale', 1.0);
    await prefs.setBool('daily_reminders_enabled', true);
    await prefs.setString('methodId', 'najaf');
    await prefs.setString('sect', 'shia');
    await prefs.setBool('isDndEnabled', false);

    // Disable DND system-side if it was enabled
    await DndService.disableDnd();

    calculatePrayerTimes(DateTime.now());
    notifyListeners();
  }

  Future<String> searchCity(String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<Location> locs = await locationFromAddress(query);
      if (locs.isNotEmpty) {
        await updateLocation(locs.first.latitude, locs.first.longitude, query);
        return 'Found: $query';
      }
      throw 'Not Found';
    } catch (e) {
      return 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
