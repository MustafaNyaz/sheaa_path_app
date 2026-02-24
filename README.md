# Qiyam Dawud (قيام داوود)

## Overview
**Qiyam Dawud** is a spiritual companion app designed to help users observe the Sunnah of Prophet Dawud (David) in prayer and sleep. It calculates the "Third of the Night" with astronomical precision to optimize your night worship (Qiyam al-Layl).

## Features
*   **Astronomical Accuracy:** Uses the `adhan` library (based on Muslim World League, Umm Al-Qura, etc.) to calculate precise prayer times.
*   **Smart Sleep Schedule:** Calculates the ideal time to sleep and wake up based on the Prophet Dawud's regimen (sleep half the night, pray one-third, sleep one-sixth).
*   **Real-Time Countdown:** Live timer showing exactly how much time remains until Qiyam, Suhur, or Fajr.
*   **Auto-Location (GPS):** Automatically detects your city and coordinates for accurate local timings.
*   **Manual Search:** Fallback option to manually search for any city worldwide.
*   **Hijri Calendar:** Displays the current Islamic date.
*   **Native RTL Support:** Optimized for Arabic users with intuitive navigation.

## Installation
1.  Download the latest APK release.
2.  Install on your Android device.
3.  On first launch, grant Location permissions to auto-detect your city.
4.  (Optional) Go to Settings to change the Calculation Method (Default: Muslim World League).

## Development
This project is built with **Flutter**.

### Key Dependencies
*   `adhan`: Prayer time calculations.
*   `geolocator` & `geocoding`: Location services.
*   `hijri`: Islamic calendar.
*   `shared_preferences`: Local data persistence.
*   `android_intent_plus`: Robust alarm setting.

### Build
To build the release APK:
```bash
flutter build apk --release
```
*Note: This project is configured for Android SDK 33 to ensure broad compatibility.*