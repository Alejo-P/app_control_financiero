# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview
Control Financiero is a Flutter application for managing personal finances. It tracks income/expenses (movimientos), budgets (presupuestos), and categories with a local SQLite database using the `sqflite` package.

## Common Commands

### Run the application
```powershell
flutter run
```

### Build for specific platforms
```powershell
# Android
flutter build apk

# iOS
flutter build ios

# Windows
flutter build windows
```

### Analyze and lint code
```powershell
flutter analyze
```

### Clean build artifacts
```powershell
flutter clean
flutter pub get
```

### Update dependencies
```powershell
flutter pub get
flutter pub upgrade
```

### Generate app icons
```powershell
flutter pub run flutter_launcher_icons
```

## Architecture

### State Management
- Uses **Provider** pattern with a single `AppState` class (`lib/app/app_state.dart`) as the central state manager
- `AppState` holds all repositories and manages global state (dark mode, current tab, selected months, etc.)
- All CRUD operations for movimientos, categorias, and presupuestos go through `AppState` methods
- State changes trigger `notifyListeners()` to update the UI

### Database Layer
- SQLite database managed by `DBHelper` singleton (`lib/core/database/db_helper.dart`)
- Database name: `control_financiero.db` (current version: 4)
- Foreign keys are enabled via `PRAGMA foreign_keys = ON`
- Database tables defined in `lib/core/database/db_tables.dart`
- Seed data and migrations in `lib/core/database/db_init_data.dart`

### Feature-Based Structure
The app follows a feature-based architecture under `lib/features/`:
- **movimientos**: Income/expense transactions with date, amount, category, and notes
- **presupuestos**: Monthly budgets linked to categories
- **categorias**: Transaction categories with icons, colors, and types
- **tipo_categorias**: Category types (e.g., "Transporte", "Alimentación")
- **historial**: Historical transaction views
- **ingresos**: Income-related features
- **ajustes**: Settings and configurations
- **shared**: Shared widgets and utilities

Each feature typically contains:
- `data/`: Repository and data source (local SQLite queries)
- `models/`: Domain models with `fromMap` and `toMap` methods
- `presentation/`: Pages/screens
- `widgets/`: Feature-specific UI components (when applicable)

### Core Layer (`lib/core/`)
- **constants/**: App-wide constants for strings, colors, and enum values
- **database/**: Database helper, table definitions, migrations, and seeds
- **formatters/**: Input formatters (money, notes)
- **models/**: Shared models like `OperationResult` and `AppBarAction`
- **theme/**: Light and dark theme definitions
- **utils/**: Utility functions for colors, dates, formatting, and icon mapping

### Navigation
- Named routes defined in `lib/app/app.dart` (routes object in MaterialApp)
- Main scaffold with bottom navigation in `lib/app/app_scaffold.dart`
- Four main tabs: Movimientos, Presupuesto, Historial, Más acciones

### Data Flow
1. UI calls methods on `AppState` (via `Provider.of<AppState>` or `context.read<AppState>()`)
2. `AppState` delegates to repository (e.g., `MovimientosRepository`)
3. Repository calls local data source which executes SQLite queries
4. Results return as `OperationResult` with success/failure messages
5. `AppState` updates state and calls `notifyListeners()`
6. UI rebuilds via `Consumer<AppState>` or `context.watch<AppState>()`

## Key Models

### Movimiento (Transaction)
- Properties: `id`, `title`, `categoryID`, `type` (ingreso/gasto), `amount`, `date`, `time`, `note`
- Types: `TipoMovimiento.ingreso` or `TipoMovimiento.gasto`

### Categoria (Category)
- Properties: `id`, `name`, `description`, `movementType`, `categoryTypeID`, `iconName`, `iconColorValue`, `isDefault`
- Links to `TipoCategoria` via `categoryTypeID`
- Has computed properties: `iconData` and `iconColor`

### Presupuesto (Budget)
- Properties: `id`, `categoryId`, `date`, `amount`
- Monthly budgets linked to specific categories

### TipoCategoria (Category Type)
- Properties: `id`, `name`, `description`
- Groups categories into types (e.g., Transport, Food, Entertainment)

## Important Patterns

### Repository Pattern
- All data access goes through repositories
- Repositories use local data sources that interact with SQLite
- Example: `MovimientosRepository` → `MovimientosLocalDataSource` → SQLite

### Month-Based Filtering
- Both movimientos and presupuestos are filtered by selected month/year
- Separate state for movements month (`selectedMovementsMonth`) and budget month (`selectedBudgetMonth`)
- Loading indicators: `isLoadingMonth` and `isLoadingBudget`

### Result Pattern
- CRUD operations return `OperationResult` with `success` and `message` properties
- `AppState` stores result in `transactionResultMessage` and `transactionSuccess`
- UI can display snackbars based on these values

### Icon and Color Storage
- Icons stored as string names (e.g., "shopping_cart") and mapped via `IconMapper.fromName()`
- Colors stored as integer values (`iconColorValue`) and converted to `Color` objects

## Development Notes

### Testing
- No test suite currently exists in this project
- The project uses `flutter_test` as a dev dependency but has no test files

### Linting
- Uses `flutter_lints` package (version 6.0.0)
- Configuration in `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml`

### Localization
- Uses `intl` package for date formatting
- No internationalization (i18n) setup; all strings are in Spanish

### Platform Support
- Configured for Android, iOS, Linux, macOS, Web, and Windows
- Icons configured for Android and iOS via `flutter_launcher_icons`

## Database Schema

### Tables
- `tipo_categorias`: id, name, description
- `categorias`: id, name, description, movement_type, category_type_id, icon_name, icon_color_value, is_default
- `movimientos`: id, title, category_id, type, amount, date, time, note
- `presupuestos`: id, category_id, date, amount
- `ingreso_presupuestado`: id, amount, date
- `meta`: key, value (metadata store)

### Foreign Keys
- `categorias.category_type_id` → `tipo_categorias.id`
- `movimientos.category_id` → `categorias.id`
- `presupuestos.category_id` → `categorias.id`

## Common Tasks

### Adding a New Feature
1. Create feature directory under `lib/features/[feature_name]/`
2. Add subdirectories: `data/`, `models/`, `presentation/`, `widgets/` (as needed)
3. Create model with `fromMap` and `toMap` methods
4. Create local data source with SQLite queries
5. Create repository that uses the data source
6. Add repository to `AppState` constructor and wire up CRUD methods
7. Create presentation pages and add routes in `lib/app/app.dart`

### Modifying the Database Schema
1. Update table definitions in `lib/core/database/db_tables.dart`
2. Increment database version in `db_helper.dart`
3. Add migration logic in `db_migrations.dart` or update `db_init_data.dart`
4. Update seed data if needed
5. Update corresponding model classes

### Adding a New Route
1. Define route name as constant or string
2. Add route entry in `MaterialApp.routes` in `lib/app/app.dart`
3. Navigate using `Navigator.pushNamed(context, '/route_name')`

### Working with AppState
- Access for reading: `context.watch<AppState>()` or `Consumer<AppState>`
- Access for writing: `context.read<AppState>()`
- Always use `notifyListeners()` after state changes in `AppState`
- Transaction results are stored in `transactionResultMessage` and `transactionSuccess`
