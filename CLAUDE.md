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
flutter test test/presentation/viewmodels/set_time_viewmodel_test.dart     # run a single test file
flutter test --plain-name "初期化時"                          # run tests matching a name
```

The app reads its Supabase credentials from `--dart-define` (see `lib/config/env_config.dart`), so
`flutter run`/`flutter test` that exercise real Supabase calls need
`--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` (see `env/env.example.json`
for the expected shape). Unit tests that mock the repository layer don't need this.

### Drift (local SQLite) codegen

`lib/data/database/database.g.dart` is generated from `lib/data/database/database.dart`.
Regenerate after changing any `Table` definition there:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Note: `AwakeDatabase`/`RoomRepository` are still constructed and provided in `main()`, but nothing
currently reads from them — see "Backend: Supabase" below.

### iOS/CocoaPods

The `ios/` project uses CocoaPods (`ios/Podfile`). After changing native iOS deps, run
`cd ios && pod install`.

## Architecture

### Backend: Supabase only

Firebase (Firestore/Auth/Storage) has been fully removed. **Supabase** (`supabase_flutter`) is the
sole remote backend for auth, database, and realtime:

- `lib/config/env_config.dart` reads `SUPABASE_URL`/`SUPABASE_ANON_KEY` from `--dart-define`;
  `Supabase.initialize(...)` runs once in `lib/main.dart`.
- `supabase/migrations/20260926061806_initial_schema.sql` defines the Postgres schema (`profiles`,
  `groups`, `groups_memberships`, `events`, `event_reports`) and RLS policies restricting reads to
  fellow group members and writes to admins (`role = 0`).
- Non-trivial multi-step operations (invitation-code join, bulk event/report creation, QR/passcode
  check-in) are implemented as Postgres RPC functions and called via `client.rpc(...)` rather than
  composed client-side — see `test/data/repositories/supabase_rpc_test.dart`.
- `MemberEventViewModel`/`RankingViewModel` subscribe to Supabase Realtime streams to detect
  status changes and event completion immediately instead of polling.
- **Drift/SQLite** (`lib/data/database/database.dart`, `RoomRepository`) still exists and is still
  constructed/provided in `main()`, but nothing reads from it anymore — treat it as inert unless
  you're actively wiring up local caching again.

### Layered structure (`lib/presentation/` + `lib/data/repositories/`)

The earlier split between flat top-level pages and per-feature `lib/<feature>/{data,domain,view,view_model}/`
modules has been consolidated into a single layering, used for every feature:

- `lib/models/` — plain data classes (`Group`, `Event`, `Profile`, `EventReport`, `RankingUser`).
- `lib/data/repositories/<feature>_repository.dart` — one file per feature holding both the
  abstract interface and its `Supabase*Repository implements` class, e.g. `GroupRepository` /
  `SupabaseGroupRepository` in `lib/data/repositories/group_repository.dart`. Also
  `auth_repository.dart`, `admin_event_repository.dart`, `member_event_repository.dart`,
  `ranking_repository.dart`.
- `lib/presentation/viewmodels/*_view_model.dart` — a `ChangeNotifier` per screen/action, taking
  its repository via constructor injection (no shared `Base*ViewModel` superclass anymore).
- `lib/presentation/views/` — widgets, grouped by feature: `event/{admin,checkin,schedule}/`,
  `group/`, `login/`, `ranking/`.

When adding a new feature, follow this layering rather than adding a flat page or a new
`lib/<feature>/` module.

### Alarms

`lib/services/alarm_service.dart` and `lib/services/vibration_service.dart` wrap the `alarm` and
`vibration` packages behind small interfaces (`AlarmService`, `VibrationService`) with `Real*`
implementations, specifically so `MyApp` in `lib/main.dart` can be tested/driven without real
platform alarms. `MyApp` listens to `AlarmService.ringing`, shows a stop dialog, and runs a
gradually-intensifying custom vibration pattern while an alarm rings; on stop it calls
`MemberEventRepository.reportWakeUp`/`reportDeparture` (Supabase RPC) to sync status back. Alarm
payloads are JSON containing `eventId` and `phase`.

### Testing conventions

Tests live under `test/presentation/viewmodels/` (mirroring `lib/presentation/viewmodels/`) and
`test/data/repositories/`, rather than one flat `test/viewmodels/` directory.

- View-model unit tests construct the view model directly (no widget pump), drive its public
  methods, and assert on its `ChangeNotifier` state/getters — see
  `test/presentation/viewmodels/set_time_viewmodel_test.dart` and
  `test/presentation/viewmodels/late_report_viewmodel_test.dart`.
- The standard DI pattern for tests is `mocktail`: define a `class MockXRepository extends Mock
  implements XRepository {}` and pass it into the view model's constructor (see
  `test/presentation/viewmodels/group_view_model_test.dart`,
  `test/presentation/viewmodels/admin_event_view_model_test.dart`, etc.). View models that also
  need to avoid real platform APIs (location, photo upload) expose optional mock injection points
  in their constructors, e.g. `LateReportViewModel`'s `mockFetchLocation`/`mockUploadPhoto`.
- There is no Firebase to mock anymore — no `flutter_test_config.dart`/global setup is needed for
  `CommonLayout` or any other widget, since none of them read `FirebaseAuth` any longer.
