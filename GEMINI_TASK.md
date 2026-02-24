# Current Development Task

**Status:** Completed
**Role:** Senior Flutter Architect
**Project:** Al-Sabiqun Al-Muqarrabun

---

## Task: Create Settings Screen

**Objective:** 
Create a new screen to manage application preferences using `shared_preferences`.

**Files to Create:**
- `lib/screens/settings_screen.dart`

**Files to Modify:**
- `lib/main.dart` (Add navigation to the new screen)

**Detailed Requirements:**

1.  **`lib/screens/settings_screen.dart`**:
    - Create a stateful widget `SettingsScreen`.
    - **UI Elements:**
        - **SwitchTile:** "Enable Daily Reminders" (Save key: `daily_reminders_enabled`).
        - **Slider:** "Font Size Scale" (Range 0.8 to 1.4, Save key: `font_scale`).
        - **Reset Button:** "Reset to Defaults".
    - **Logic:**
        - Load values from `SharedPreferences` in `initState`.
        - Save values immediately when changed.
    - **Styling:**
        - Use `Scaffold` with `AppBar(title: Text('الإعدادات'))`.
        - Use the project theme (Cairo font, Deep Blue colors).
        - Ensure strictly RTL layout compatibility.

2.  **`lib/main.dart`**:
    - In the `MainScreen`'s `AppBar`, add an `actions` button.
    - Icon: `Icons.settings`.
    - Action: Navigate to `SettingsScreen`.

---

**Instructions for Agent:**
Please implement the changes described above. Ensure all code is Null Safe and follows Material 3 guidelines.