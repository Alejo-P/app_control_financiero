# AGENTS.md

Guidance for agents working in this repository. Check the code before assuming a description is still accurate.

## Response style

The reader has ADHD. Responses should make a concrete action easy:

1. Start with the answer or next action: command, path, or snippet. Number multi-step work, with one bounded action per step and lists of up to five items.
2. State progress each turn (for example, "step 3 of 5 done") and give time estimates in minutes or seconds.
3. End with one next action that can be completed in under two minutes. Avoid preambles, recaps, and generic closers.
4. Finish the current issue before raising another. After a change, explain what now works; for errors, state the location, cause, and fix.
5. Explain fully when asked. Confirm before destructive actions. If the request is ambiguous, ask one short question. After three failed fixes, stop and identify the doubtful assumption.

## Project and environment

Control Financiero is a Flutter/Dart personal finance application, branded as "Mi Presupuesto". It uses Provider for state management, SQLite with `sqflite` for financial data, and Hive for part of its local state.

- `pubspec.yaml` defines dependencies, the Dart requirement, and the release version; `lib/core/constants/app_strings.dart` contains the name, displayed version, and database constants.
- The interface is in Spanish. `lib/app/app.dart` configures `es_EC` and Flutter localization delegates; `intl` provides formatting.
- `lib/main.dart` initializes Hive, notifications, and time zones; the configured local time zone is `America/Guayaquil`.
- Android, iOS, Linux, macOS, Windows, and Web directories exist. Their presence does not prove that all services work on every platform: check dependencies and uses of `dart:io`.
- Android has `dev` and `prod` flavors. `lib/core/config/app_config.dart` reads `FLAVOR` through `String.fromEnvironment`; pass both the native flavor and the Dart define.

## Common commands

Run from the repository root in PowerShell.

### Android development

```powershell
flutter pub get
flutter run --flavor dev --dart-define=FLAVOR=dev
```

### Production APK

```powershell
flutter build apk --release --flavor prod --dart-define=FLAVOR=prod
```

Typical output: `build/app/outputs/flutter-apk/app-prod-release.apk`. Gradle takes `versionName` and `versionCode` from the Flutter version; review signing and configuration in `android/app/build.gradle.kts` before distribution. Release currently uses debug signing.

### Verification

```powershell
flutter analyze
flutter test
# Example of a focused test:
flutter test test/features/presupuestos/budget_transfer_test.dart
# Diff hygiene:
git diff --check
```

### Icons

```powershell
dart run flutter_launcher_icons
```

Use `flutter clean` only when the diagnosis justifies it. Do not run `flutter pub upgrade` as a routine part of a fix: it changes dependencies.

## Architecture and entry points

| Area | Location and responsibility |
| --- | --- |
| State | `lib/app/app_state.dart`: `AppState`, repositories, selected periods, loading, and operation results |
| Navigation | `lib/app/app.dart`: named routes; `lib/app/app_scaffold.dart` and `lib/app/app_bottom_nav.dart`: main navigation |
| Persistence | `lib/core/database/`: opening SQLite, tables, seeds, and backup data access |
| Services | `lib/core/services/`: notifications, reminder scheduling, navigation, and backups |
| Shared infrastructure | `lib/core/`: constants, models, formatting, themes, utilities, configuration, and tutorials |

Features live in `lib/features/`: `movimientos`, `presupuestos`, `categorias`, `tipo_categorias`, `ingresos`, `historial`, `ajustes`, `notificaciones`, `recordatorios`, and `shared`. They usually contain `data/`, `models/`, `presentation/`, and, where applicable, `widgets/`.

### Data flow

1. The UI reads through `context.watch<AppState>()` or `Consumer<AppState>` and executes actions through `context.read<AppState>()`.
2. `AppState` delegates domain operations to the corresponding repository.
3. The repository calls the local data source, which queries or writes to SQLite.
4. Operations using `OperationResult<T>` return `success`, `message`, and `data`; reads may return models or lists directly.
5. `AppState` reloads the affected state and notifies the UI. Transaction messages are exposed as `transactionResultMessage` and `transactionSuccess`.

Backup and notification services have their own persistence access. Review their paths in addition to the CRUD flow when a change affects them.

### Periods and navigation

- Transactions and budgets use independent periods: `selectedMovementsMonth` and `selectedBudgetMonth`; history uses `selectedHistoryMonth`.
- Loads have identifiers (`_movementsLoadId`, `_budgetLoadId`, `_historyLoadId`) to discard stale responses. Preserve this protection when modifying asynchronous queries.
- The main tabs are Movimientos, Presupuesto, Historial, and the settings/more actions screen.
- When returning from saving or deleting in a form, respect the navigation result and refresh views that maintain their own local queries.
- Do not modify shared lists to introduce synthetic options such as "Todas"; create a local copy.

## Database and models

The source of truth is `lib/core/database/db_tables.dart`.

- `DBHelper` opens `control_financiero.db` in the documents directory and enables `PRAGMA foreign_keys = ON`.
- The current version is `appDBVersion = 1`, defined in `lib/core/constants/app_strings.dart`.
- `onCreate` creates tables and loads data from `db_init_data.dart` through functions in `db_seeds.dart`.
- `onUpgrade` is commented out in `db_helper.dart`; there is no active migration. Do not assume that incrementing the version updates existing databases.
- For schema changes, agree on the scope of previous installations before adding migrations. Preserve data when updating an installed app.

### Tables

| Table | Columns |
| --- | --- |
| `tipo_categorias` | `id`, `name`, `description` |
| `categorias` | `id`, `name`, `description`, `movement_type`, `category_type_id`, `icon_name`, `icon_color_value`, `is_default` |
| `movimientos` | `id`, `title`, `category_id`, `amount`, `date`, `time`, `note` |
| `presupuestos` | `id`, `category_id`, `date`, `amount`, `repeat_budget` |
| `ingreso_presupuestado` | `id`, `amount`, `date` |
| `notificaciones` | `id`, `title`, `description`, `type`, `is_read`, `icon`, `icon_color`, `extra_data`, `object_id`, `created_at` |
| `budget_notification_config` | `id`, `category_id`, `threshold`, `is_enabled`, `is_default`, `created_at` |
| `movement_notification_config` | `id`, `type_key`, `is_enabled`, `is_default`, `created_at` |
| `budget_notification_events` | `id`, `category_id`, `year`, `month`, `threshold`, `created_at` |
| `recordatorios` | `id`, `title`, `description`, `category_id`, `scheduled_at`, `completed`, `enabled`, `recurrencia`, `is_default` |
| `meta` | `key`, `value` |

Foreign keys link categories to category types, and transactions, budgets, budget events, and reminders to categories. Review dependencies and transactions when deleting categories; do not assume cascading deletion.

### Relevant model details

- `Movimiento` contains `id`, `title`, `categoryID`, `amount`, `date`, `time`, and `note`. It does not contain `type`: income/expense is obtained from `categorias.movement_type`; `DetalleMovimiento` exposes `movementType`.
- `Movimiento.toMap()` stores the date as `yyyy-MM-dd` and the time as `HH:mm` separately. Do not assume transactions already use `created_at` because other tables have it.
- `Presupuesto` contains `id`, `categoryId`, `date`, `amount`, and `repeatBudget`; queries operate by month/year.
- `Categoria` stores icon names and integer color values; it converts them through `IconMapper` and `Color`.
- `Recordatorio` and its detail/form models are in `lib/features/recordatorios/models/`; review recurrence and date when changing its scheduling.

## Rules for sensitive changes

### Transaction search

The paginated query is in `lib/features/movimientos/data/movimientos_local_datasource.dart`, method `querySearchPage`.

- Apply the same filters to the count and rows before `LIMIT/OFFSET`.
- Keep pages of 20 results and stable ordering: `date DESC`, `time DESC`, `id DESC`.
- Preserve protection against stale responses and review filters, pages, and refresh behavior after editing/deleting.

### Budgets and transfers

- Review the UI, `AppState`, repository, and data source; UI validation does not guarantee that persistence prevents the same operation.
- A replacement requires confirmation; canceling must result in zero writes.
- Test missing income, zero, the exact limit, and replacement when amount rules change.

### Notifications and reminders

- Review `lib/core/services/notification_service.dart` and `reminder_schedule.dart`, as well as `AppState` and affected data sources.
- Scheduling paths use `_scheduleWithFallback`: preserve the date, payload, and recurrence when retrying an exact alarm as an inexact alarm.
- Distinguish a notification stored in SQLite from an alarm scheduled in the system. Automated tests do not demonstrate actual delivery on a device.

### Backups

Review `BackupService`, `BackupContent`, `backup_local_datasource.dart`, `BackupCipher`, and `BackupFileWriter` when changing exported/restored data. Verify integrity, included preferences, and error handling; avoid logging passwords or sensitive content.

## Tests and completion checks

A test suite exists in `test/`, covering widgets, `AppState`, searches, transfers, categories, reminders, notifications, backups, encryption, and tutorials. Shared state test doubles are in `test/support/app_state_fakes.dart`.

1. Inspect `git status --short` and the diff before editing; preserve the user's existing changes.
2. Before fixing logic, explain the cause, reproduction, and trade-offs of the proposed solution.
3. Run analysis and tests appropriate to the change. For documentation-only changes, review content, paths, and `git diff --check`.
4. Add tests when they verify real risks or edge cases; do not create tests that merely reproduce the implementation or require them for reversible, low-impact changes.
5. Report what was verified automatically, what was blocked, and what requires a device; finish with a concrete manual test when appropriate.

`analysis_options.yaml` uses `flutter_lints`. Do not report a check as passed if the tool could not run.
