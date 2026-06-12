# Anchor — Known Issues & Fixes

This file tracks the current issues, errors, and missing screens identified in the Anchor Flutter app, along with the fixes applied.

---

## 1. Widget Sync Service — Import & Quality Issues

**File:** `lib/features/streak/services/widget_sync_service.dart`

**Issues:**
- Duplicate import of `streak_day.dart` (imported as both `../../streak/models/streak_day.dart` and `../models/streak_day.dart`).
- `PlatformException` catch blocks in `syncStreakData()` and `syncTaskData()` were empty — errors were silently swallowed.
- Hardcoded `accentColorHex: "#C6F52C"` instead of deriving the accent from `AnchorTheme.accent`.
- `streakDaysProvider` is imported from `independence_clock_screen.dart`, creating a service → screen dependency. This is kept for now to avoid a larger refactor, but ideally providers should live in a shared location.

**Fixes applied:**
- Removed duplicate `streak_day.dart` import.
- Added `debugPrint` logging inside catch blocks.
- Added `ColorHex.toHex()` extension in `lib/core/design/anchor_theme.dart` and used `AnchorTheme.accent.toHex()`.

---

## 2. Duplicate Import in Independence Clock Screen

**File:** `lib/modules/independence_clock/independence_clock_screen.dart`

**Issues:**
- `../../features/streak/models/streak_day.dart` was imported twice on consecutive lines.
- Several unused imports: `dart:math`, `package:drift/drift.dart`, and `../../data/local/database.dart`.
- `_selectedMonth` field was declared and initialized but never used.

**Fixes applied:**
- Removed the duplicate import line.
- Removed the unused imports.
- Removed the unused `_selectedMonth` field and its `initState` override.

---

## 3. No Dedicated Widgets Screen

**Issue:**
- The app has a working `WallpaperScreen` but no Flutter screen for previewing or pinning the Android home-screen widgets.
- The widgets icon in the Independence Clock header navigated to `WallpaperScreen`.
- The Morning Brief popup menu item "Wallpaper & Widgets" also navigated to `WallpaperScreen`.

**Fixes applied:**
- Created `lib/modules/independence_clock/widgets_screen.dart` with:
  - Streak widget preview + "Pin Streak Widget" button.
  - Tasks widget preview + "Pin Tasks Widget" button.
- Updated `IndependenceClockScreen` widgets icon to push `WidgetsScreen`.
- Updated `MorningBriefScreen` popup menu to push `WidgetsScreen`.
- Added `/widgets` route to `lib/core/router/app_router.dart`.

---

## 4. Missing Native `pinTasksWidget` Method

**File:** `android/app/src/main/kotlin/com/example/anchor/MainActivity.kt`

**Issue:**
- The widget method channel only exposed `pinStreakWidget`.
- There was no way to request pinning of the Tasks widget from Flutter.

**Fix applied:**
- Added a `pinTasksWidget` branch in the `WIDGET_CHANNEL` handler, mirroring `pinStreakWidget` but using `TasksWidgetProvider`.
- Added `WidgetSyncService.pinTasksWidget()` in Dart.

---

## 5. Settings Screen — Only Streak Widget Pin Button

**File:** `lib/modules/settings/settings_screen.dart`

**Issue:**
- HOME WIDGET section only had "Pin Streak Widget".

**Fix applied:**
- Added "Pin Tasks Widget" button below the streak button with the same snackbar feedback.

---

## 6. Clock Screen — Hardcoded 365-Day Window

**File:** `lib/modules/independence_clock/independence_clock_screen.dart`

**Issue:**
- `totalDays` was hardcoded to `365`.
- `startDate` was inferred as `goalDate.subtract(Duration(days: 365))` inside `_buildHeroCard`, causing repeated re-calculation.

**Fix applied:**
- Compute `totalDays` from `startDate` to `goalDate` in `build()` and pass `startDate` into `_buildHeroCard`.
- Default to a 1-year window when no explicit start date is stored.

---

## 7. Clock Screen — Target Date Picker

**File:** `lib/modules/independence_clock/independence_clock_screen.dart`

**Issue reported in `issue.md`:**
- "target date is not able to update or set but in setting it working"

**Fix applied:**
- Verified `_pickDate()` already calls `settingsDao.updateTargetDate()` and invalidates `settingsProvider`.
- Added explicit invalidation of `daysRemainingProvider` and `independenceDateProvider` after the date is updated to ensure all consumers refresh.

---

## 8. Clock Screen — "Remove the Timer on Top"

**File:** `lib/modules/independence_clock/independence_clock_screen.dart`, `lib/modules/independence_clock/widgets/clock_widgets.dart`

**Issue reported in `issue.md`:**
- "remove the timer on top"

**Fix applied:**
- The header has no live countdown timer; it only shows "Student OS", date selector, and icons.
- The hero card contains a `CountdownRing` with a repeating pulse animation that could be perceived as a "timer".
- Added an `animate` parameter to `CountdownRing` (default `true`) so the pulse can be disabled where desired.

---

## 9. Wallpaper Screen Still Works

**File:** `lib/modules/independence_clock/wallpaper_screen.dart`

**Status:** No changes needed. The existing "Apply Now" button and configuration panel remain functional.

---

## Verification Checklist

- [x] `flutter build apk --debug` completes successfully.
- [ ] `flutter analyze` in `anchor/` reports no import/duplicate errors (remaining warnings are pre-existing `withOpacity` deprecation warnings across the codebase).
- [ ] Clock → widgets icon opens `WidgetsScreen`.
- [ ] Morning Brief → "Wallpaper & Widgets" opens `WidgetsScreen`.
- [ ] Clock → wallpaper icon still opens `WallpaperScreen`.
- [ ] Both "Pin Streak Widget" and "Pin Tasks Widget" buttons trigger the Android widget picker on API 26+.
- [ ] Clock date picker updates the countdown immediately.
- [ ] Settings screen shows both widget pin buttons.
