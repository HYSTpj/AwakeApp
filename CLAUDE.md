# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

"HYST" (package name `flutter_application_1`) is a Flutter app that helps groups coordinate morning
wake-up/meetup events: create a group, schedule an event with a destination and arrival time, set
wake-up/departure alarms, check in via QR code or GPS, and report/rank lateness. Code comments and
UI strings are largely in Japanese.

## Commands

```bash
flutter pub get                 # install dependencies
flutter run                     # run the app (defaults to a connected device/simulator)
flutter analyze                 # static analysis (uses analysis_options.yaml / flutter_lints)
flutter test                    # run all tests
flutter test test/set_time/set_time_viewmodel_test.dart     # run a single test file
flutter test --plain-name "初期化時"                          # run tests matching a name
```

### Drift (local SQLite) codegen

`lib/database/database.g.dart` is generated from `lib/database/database.dart`. Regenerate after
changing any `Table` definition there:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### iOS/CocoaPods

The `ios/` project uses CocoaPods (`ios/Podfile`). After changing native iOS deps, run
`cd ios && pod install`.

## Architecture

### Two backends + one local cache

- **Firebase (Firestore + Auth + Storage)** is the primary remote backend. Firestore collections
  (`events`, `groups`, `groups_memberships`, `profiles`, etc.) are accessed directly from
  repository classes such as `lib/data/event_repository.dart`, `lib/data/group_repository.dart`,
  `lib/data/profiles_repository.dart`, and `lib/data/auth_repository.dart`. `firebase_storage` is
  used for uploaded photos (late-report evidence, avatars).
- **Drift/SQLite** (`lib/database/database.dart`) is a local offline cache. Tables mirror the
  Firestore schema (`Profiles`, `Groups`, `GroupMemberships`, `Events`, `EventReports`).
  `lib/data/repositories/room_repository.dart` shows the pattern: a `watch*` stream backed by
  Drift, plus a `syncFromFirebase(id, data)` method that upserts Firestore snapshots into the
  local DB.
- **Supabase** is initialized in `lib/main.dart` (`Supabase.initialize(...)`) but not yet used
  anywhere else in the codebase — treat it as present for a future migration, not a source of
  truth today.

Both `AwakeDatabase` and `RoomRepository` instances are constructed once in `main()` and provided
app-wide via `provider`'s `MultiProvider`/`Provider.value`.

### Two coexisting code layouts

The codebase is mid-migration from a flat "pages" structure to a feature-based MVVM structure —
expect both when navigating:

- **Legacy flat pages** live directly under `lib/` (e.g. `create_event_page.dart`,
  `memberstatus_page.dart`, `set_time_page.dart`, `qr_scanner_page.dart`). Some of these already
  delegate business logic to a `ChangeNotifier` view model in `lib/viewmodels/`
  (`late_report_viewmodel.dart`, `set_time_viewmodel.dart`, `member_check_in_viewmodel.dart`).
- **Newer feature modules** live under `lib/<feature>/` with `data/`, `domain/`, `view/`, and
  `view_model/` subfolders — see `lib/event/` and `lib/group/` for the intended target shape:
  - `domain/*_entity.dart` — plain data model for the feature.
  - `data/*_data.dart` or `data/*_repository*.dart` — Firestore access, implementing an
    interface defined alongside the entity (e.g. `GroupRepository` interface implemented by
    `GroupRepositoryImpl`).
  - `view_model/*_view_model.dart` — a `Base*ViewModel extends ChangeNotifier` with concrete
    subclasses per screen/action (e.g. `CreateGroupViewModel`, `AddGroupViewModel`,
    `DeleteGroupViewModel`, `GroupListViewModel` all extend `BaseGroupViewModel`).
  - `view/*_view.dart` — the widget, consuming its view model via `provider`.

  There's also `lib/domain/` + `lib/data/repositories/` (singular, top-level) for the
  `EventReport` feature, following the same interface/impl split
  (`lib/domain/repositories/i_event_report_repository.dart` /
  `lib/data/repositories/event_report_repository_impl.dart`).

When adding a new feature, prefer the `lib/<feature>/{data,domain,view,view_model}/` pattern over
adding another flat page.

### Alarms

`lib/alarm.dart`, `lib/services/alarm_service.dart`, and `lib/services/vibration_service.dart`
wrap the `alarm` and `vibration` packages behind small interfaces (`AlarmService`,
`VibrationService`) with `Real*` implementations, specifically so `MyApp` in `lib/main.dart` can
be tested/driven without real platform alarms. `MyApp` listens to `AlarmService.ringing`, shows a
stop dialog, and runs a gradually-intensifying custom vibration pattern while an alarm rings; on
stop it calls `EventRepository.stopAlarmAndUpdateStatus` to sync status back to Firestore. Alarm
payloads are JSON containing `eventId` and `phase`.

### Testing conventions

Tests live under `test/<feature>/`, mirroring the `lib/<feature>/` layout (e.g.
`test/set_time/`, `test/late_report/`, `test/group/`) rather than one flat `test/viewmodels/`
directory.

- View-model unit tests construct the view model directly (no widget pump), drive its public
  methods, and assert on its `ChangeNotifier` state/getters — see
  `test/set_time/set_time_viewmodel_test.dart` and `test/late_report/late_report_viewmodel_test.dart`.
  View models that need to avoid hitting real platform APIs in tests expose optional mock
  injection points in their constructors (e.g. `LateReportViewModel`'s `mockFetchLocation` /
  `mockUploadPhoto`), or accept an interface/Repository that `mocktail` can mock directly (e.g.
  `test/group/create_group_view_model_test.dart` mocks the `GroupRepository` interface).
- Widget tests that render `CommonLayout` (directly or via a page) rely on `Firebase.initializeApp()`
  having run, because `CommonLayout` reads `FirebaseAuth.instance.currentUser`. This is handled
  automatically for every test file via `test/flutter_test_config.dart`, which calls
  `setupFirebaseCoreMocks()` (`test/test_helpers/firebase_mock_setup.dart`) before any test's
  `main()` runs — no per-file setup is needed. That helper only fakes `firebase_core`
  (`FirebasePlatform`), not `firebase_auth`'s platform channel; it's sufficient for the synchronous
  `.currentUser` null-check `CommonLayout` does, but a test that needs `FirebaseAuth` to actually
  sign in/out or stream auth state will need to extend the fake (or fake `FirebaseAuthPlatform`
  too) rather than assume it's fully covered.
