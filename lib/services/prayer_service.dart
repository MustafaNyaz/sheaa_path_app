import 'package:adhan/adhan.dart';
import '../models/prayer_times_model.dart';

class PrayerService {

  CalculationParameters getParameters(String id) {
    switch (id) {
      case 'umm_al_qura': return CalculationMethod.umm_al_qura.getParameters();
      case 'egyptian': return CalculationMethod.egyptian.getParameters();
      case 'karachi': return CalculationMethod.karachi.getParameters();
      case 'north_america': return CalculationMethod.north_america.getParameters();
      case 'dubai': return CalculationMethod.dubai.getParameters();
      case 'moon_sighting_committee': return CalculationMethod.moon_sighting_committee.getParameters();
      case 'tehran': return CalculationMethod.tehran.getParameters();
      case 'najaf': 
        // Shia Ithna Ashari (Leva Institute, Qum) standard
        // Fajr 16, Maghrib 4, Isha 14
        final params = CalculationMethod.other.getParameters();
        params.fajrAngle = 16.0;
        params.maghribAngle = 4.0;
        params.ishaAngle = 14.0;
        params.method = CalculationMethod.other;
        return params;
      case 'mwl': 
      default: return CalculationMethod.muslim_world_league.getParameters();
    }
  }

  String getMethodName(String id) {
    switch (id) {
      case 'umm_al_qura': return "أم القرى (Umm Al-Qura)";
      case 'egyptian': return "المساحة المصرية (Egyptian)";
      case 'karachi': return "جامعة كراتشي (Karachi)";
      case 'north_america': return "أمريكا الشمالية (ISNA)";
      case 'dubai': return "دبي (Dubai)";
      case 'moon_sighting_committee': return "لجنة رؤية الهلال (Moon Sighting)";
      case 'tehran': return "جامعة طهران (Tehran)";
      case 'najaf': return "الحوزة العلمية (Najaf/Qum - Shia)";
      case 'mwl': return "رابطة العالم الإسلامي (MWL)";
      default: return id;
    }
  }

  List<String> getMethodsBySect(String sect) {
    if (sect == 'shia') {
      return ['najaf', 'tehran']; 
    } else {
      // Sunni
      return [
        'mwl', 
        'umm_al_qura', 
        'egyptian', 
        'karachi', 
        'north_america', 
        'dubai', 
        'moon_sighting_committee'
      ];
    }
  }

  PrayerTimesModel calculateTimes(double lat, double lng, String methodId, DateTime date) {
    final coordinates = Coordinates(lat, lng);
    final params = getParameters(methodId);
    params.madhab = Madhab.shafi; // Standard, Hanbali/Maliki/Shafi use same Asr. Hanafi is different but usually covered by UI toggle if needed.

    final dateComps = DateComponents.from(date);
    final prayerTimesToday = PrayerTimes(coordinates, dateComps, params);
    
    final DateTime tomorrow = date.add(const Duration(days: 1));
    final DateComponents tomorrowComps = DateComponents.from(tomorrow);
    final PrayerTimes prayerTimesTomorrow = PrayerTimes(coordinates, tomorrowComps, params);

    final ishaTime = prayerTimesToday.isha;
    final fajrTime = prayerTimesTomorrow.fajr;
    DateTime? wakeTime;
    DateTime? stopTime;

    final Duration nightDuration = fajrTime.difference(ishaTime);
    final int partMs = (nightDuration.inMilliseconds / 6).round();

    wakeTime = ishaTime.add(Duration(milliseconds: partMs * 3));
    stopTime = wakeTime.add(Duration(milliseconds: partMs * 2));
  
    return PrayerTimesModel(
      ishaTime: ishaTime,
      fajrTime: fajrTime,
      wakeTime: wakeTime,
      stopTime: stopTime,
      dhuhrTime: prayerTimesToday.dhuhr,
      asrTime: prayerTimesToday.asr,
      maghribTime: prayerTimesToday.maghrib,
    );
  }
}