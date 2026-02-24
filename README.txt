# Al-Sabiqun App

This is a complete Flutter application based on the content of "Prophets_Timeline_and_Stories.docx".

## Features
- **Prophets Timeline:** Explore the stories and timeline of the Prophets.
- **The Plan (Al-Sabiqun):** Daily and Monthly checklists for spiritual growth.
- **Prayer Guide:** Detailed guides for Sunan Rawatib, Duha, and Qiyam al-Layl.
- **Reminders:** Built-in notifications for Duha (9:00 AM) and Qiyam (3:00 AM).

## How to Build

**Important Note:** The current project path contains Arabic characters (`السابقون_المقربون`), which causes the Android build system (Gradle) to fail.

To build and run the app:
1. Move the `al_sabiqun_app` folder to a path with only English characters (e.g., `C:\Projects\al_sabiqun_app`).
2. Open a terminal in that new folder.
3. Run `flutter pub get`.
4. Run `flutter run` to launch on your connected device or emulator.
   Or run `flutter build apk` to generate an installation file.

## Data Source
The content is dynamically loaded from `assets/data.json`, which was extracted from your Word document.
