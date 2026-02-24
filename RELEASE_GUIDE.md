# Release Guide & Troubleshooting

## 1. Build Success
Your optimized App Bundle has been built successfully:
`build\app\outputs\bundle\release\app-release.aab`

Upload this file to the **Google Play Console** (Internal Testing or Production track).

## 2. Fixing Google Login (CRITICAL)
Google Login often fails in the "Release" version because the digital fingerprint (SHA-1) of your release keystore is missing from Firebase.

**Step 1: Get your Release SHA-1**
We have extracted this for you. 

**Your Upload Key SHA-1:**
`B3:06:2E:97:3C:5E:52:01:B7:3E:95:E1:9E:6B:69:AA:39:75:82:AB`

**Step 2: Add to Firebase**
1. Copy the **SHA-1** fingerprint from the output.
2. Go to [Firebase Console](https://console.firebase.google.com/).
3. Navigate to **Project Settings** -> **Your Apps** -> **Android**.
4. Click **Add fingerprint** and paste the SHA-1.
5. **Save.**

**Step 3: Add Play Console SHA-1 (App Signing)**
Google Play re-signs your app. You must also add the *Google Play App Signing* key to Firebase.
1. Go to **Google Play Console** -> **Release** -> **Setup** -> **App Integrity**.
2. Look for the "App signing key certificate".
3. Copy the **SHA-1** fingerprint.
4. Add this *second* SHA-1 to Firebase Console as well.

## 3. Fixing Athan Triggers
We have applied a code fix to ensuring prayers are scheduled correctly:
- If you open the app after a prayer time (e.g., Fajr), the app now correctly calculates tomorrow's Fajr time and schedules it.
- We added `USE_FULL_SCREEN_INTENT` permission to ensure the alarm wakes the screen on Android 12+.

## 4. Email Login
Ensure that **Email/Password** provider is enabled in:
**Firebase Console** -> **Authentication** -> **Sign-in method**.

## 5. iOS Release (No App Store Listing Required)
If you want iOS delivery without a public App Store listing, use one of these:

- **Ad Hoc distribution** (direct install to registered UDID devices)
- **Development distribution** (Xcode install to connected devices)
- **TestFlight internal/external** (uses App Store Connect but not public listing)

### iOS Build Steps (on macOS)
1. Run `flutter pub get`
2. Run `cd ios && pod install`
3. Run `flutter build ipa --release`
4. Open `ios/Runner.xcworkspace` in Xcode for signing/distribution export

### iOS Sanity Checklist
- Notification permission appears and can be granted
- Location permission appears and city updates correctly
- Athan test notification plays sound (`athan.aiff`)
- Foreground notification banner appears while app is open
- Prayer notifications schedule for upcoming times after app launch

### GitHub Build (No Local Mac)
This repo now includes a GitHub Actions workflow:
- `.github/workflows/ios-build.yml`

How to use:
1. Push to `main`/`master` for unsigned iOS CI build, or run it manually from Actions.
2. In manual run, choose:
   - `build_type: unsigned` for quick CI artifact
   - `build_type: signed` for distributable IPA

Required GitHub Secrets for signed build:
- `IOS_CERTIFICATE_BASE64`
- `IOS_CERTIFICATE_PASSWORD`
- `IOS_MOBILEPROVISION_BASE64`
- `IOS_KEYCHAIN_PASSWORD`

Optional Firebase iOS secret:
- `IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64`
