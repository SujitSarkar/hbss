# Maori Health

A Flutter application built with **Clean Architecture**, **BLoC** state management, and **GoRouter** navigation.

## Documentation

- **[AI knowledge base](docs/ai-knowledge-base.md)** — stack, layers, DI, commands, and conventions for contributors and coding agents.
- **[AGENTS.md](AGENTS.md)** — short entry point for automated agents (points to the knowledge base).
- **[Clean architecture notes](docs/clean-architecture-validation.md)** — baseline layering findings and technical debt.

## System Requirements & Versions

| Technology | Version |
|-----------|---------|
| **Flutter** | 3.41.2 |
| **JDK** | 17.0.12 |
| **Xcode** | 26.2 |
| **Android API Level** | 36 |

## Setup

### 1. Install Flutter via FVM

This project pins the Flutter SDK with [FVM](https://fvm.app/). Install FVM first, then:

```bash
cd /path/to/hbss
fvm install 3.41.2
fvm use 3.41.2
```

Use `fvm flutter` (or a shell alias) for all Flutter commands so the correct SDK is used.

### 2. Install Dependencies

```bash
fvm flutter pub get
```

### 3. Generate ObjectBox code

Local persistence uses [ObjectBox](https://objectbox.io/). Entity definitions live under `lib/data/objectbox/`; the generated store and bindings are written to `lib/objectbox.g.dart`. Regenerate that file whenever you change `@Entity` classes (or on a fresh clone if the file is missing):

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

For active development, you can keep codegen in sync automatically:

```bash
fvm dart run build_runner watch --delete-conflicting-outputs
```

### 4. Run the App

```bash
# Development flavor
fvm flutter run --flavor dev -t lib/main_dev.dart

# Production flavor
fvm flutter run --flavor prod -t lib/main_prod.dart
```

## Useful Commands

```bash
# ObjectBox — regenerate lib/objectbox.g.dart after entity changes
fvm dart run build_runner build --delete-conflicting-outputs

# Static analysis (run before commits)
fvm flutter analyze

# Tests
fvm flutter test

# Build APK — development
fvm flutter build apk --profile --flavor dev -t lib/main_dev.dart

# Build APK — production
fvm flutter build apk --profile --flavor prod -t lib/main_prod.dart
```

### VS Code / Cursor

Launch configurations live in `.vscode/launch.json`:

- **Dev** — debug, development environment
- **Prod** — debug, production environment
- **Dev(Profile)** — profile mode, development
- **Prod(Profile)** — profile mode, production

## Project Structure

```
lib/
├── main_dev.dart                  # Dev entry point
├── main_prod.dart                 # Prod entry point
├── main_common.dart               # Shared bootstrap (DI, runApp)
│
├── core/                          # App-wide infrastructure
│   ├── config/                    # Env, assets, strings
│   ├── di/                        # GetIt: service, network, feature modules
│   ├── error/                     # Failures & exceptions
│   ├── network/                   # Dio client, API endpoints, network checker
│   ├── result/                    # Result<T> success/failure
│   ├── router/                    # GoRouter & route names
│   ├── storage/                   # Secure storage & local cache
│   ├── theme/                     # Colors, typography, Material 3 theme
│   └── utils/                     # Validators, extensions, helpers
│
├── data/                          # Data layer
│   ├── <feature>/datasources/     # Remote (and local) data sources
│   ├── <feature>/models/          # DTOs / JSON models
│   ├── <feature>/repositories/    # Repository implementations
│   └── app/repositories/          # e.g. theme preference impl
│
├── domain/                        # Domain layer
│   ├── <feature>/entities/        # Business objects
│   ├── <feature>/repositories/    # Repository contracts (abstract)
│   ├── <feature>/usecases/        # One use case per application action
│   └── app/                       # e.g. theme preference port
│
└── presentation/                  # UI layer
    ├── app/                       # Root app widget, AppBloc (theme)
    ├── auth/                      # Login, password flows
    ├── dashboard/                 # Home dashboard
    ├── schedule/                  # Schedules
    ├── timesheet/                 # Timesheets
    ├── notification/              # Notifications
    ├── asset/                     # Assets
    ├── client/, employee/         # Lookup lists for filters, etc.
    ├── app_settings/              # Remote app settings
    ├── lookup_enums/              # Shared enum lookups
    ├── profile/, settings/        # Profile & settings UI
    ├── splash/                    # Splash
    └── shared/                    # Shared widgets, bottom nav
```

## Architecture

The app uses **Clean Architecture** with three layers and strict dependency direction:

| Layer | Path | Role |
|-------|------|------|
| **Presentation** | `lib/presentation/` | Pages, widgets, **BLoC** (UI state only) |
| **Domain** | `lib/domain/` | Entities, **repository interfaces**, **use cases** |
| **Data** | `lib/data/` | **Data sources** (API, cache), models, **repository implementations** |

### Dependency rule

```text
Presentation  →  Domain use cases  →  Domain repositories (abstract)
                       ↑
Data layer implements domain repositories; data sources are only used inside repository implementations.
```

- **BLoCs depend on use cases**, not on repositories or data sources. Use cases orchestrate calls to repository interfaces.
- **Remote/local data sources** are registered in DI for repository implementations only, not for BLoCs.

Feature wiring is centralized in [`lib/core/di/feature_module.dart`](lib/core/di/feature_module.dart): register data sources → repository impl → use cases (often `registerLazySingleton`) → `registerFactory` for the feature BLoC.

### Known layering notes

Some repository contracts still expose data-layer DTOs; a short baseline write-up and follow-up ideas are in [`docs/clean-architecture-validation.md`](docs/clean-architecture-validation.md). Refactoring those to pure domain types is a separate effort.

### Dependency Injection (GetIt)

Modules are composed in [`lib/main_common.dart`](lib/main_common.dart) (or equivalent bootstrap):

1. **Service module** — `SecureStorageService`, `LocalCacheService`, etc.
2. **Network module** — `DioClient`, `NetworkChecker`
3. **Feature module** — [`registerFeatureModule`](lib/core/di/feature_module.dart): per-feature data sources, repositories, use cases, BLoCs

### Environment Configuration

| Environment | Entry | Purpose |
|-------------|--------|---------|
| Development | `lib/main_dev.dart` | Dev API base URL via `EnvConfig` |
| Production | `lib/main_prod.dart` | Production API base URL |

See [`lib/core/config/env_config.dart`](lib/core/config/env_config.dart) for values.

### Navigation

- **GoRouter** with named routes ([`lib/core/router/app_router.dart`](lib/core/router/app_router.dart))
- Bottom navigation across main sections (dashboard, schedule, timesheet, notifications, settings/profile as routed)

### Theming

- Primary accent aligned with brand green
- Material 3, Poppins (see `core/theme/`)
- Light / dark / system: persisted via domain `ThemePreferenceRepository` and use cases consumed by `AppBloc`

## Adding a New Feature

1. **Domain:** Add entities under `lib/domain/<feature>/entities/`.
2. **Domain:** Define the repository **interface** in `lib/domain/<feature>/repositories/`.
3. **Domain:** Add **use cases** in `lib/domain/<feature>/usecases/` — one class per user-facing action, with a `call(...)` method delegating to the repository.
4. **Data:** Add remote (or local) **data sources** in `lib/data/<feature>/datasources/`.
5. **Data:** Add **models** for JSON/API shapes in `lib/data/<feature>/models/`.
6. **Data:** Implement the repository in `lib/data/<feature>/repositories/`, injecting data sources and mapping models to entities where applicable.
7. **Presentation:** Add **BLoC** (events, states, bloc) under `lib/presentation/<feature>/bloc/`. Inject **only use cases** into the BLoC constructor.
8. **Presentation:** Build pages and widgets under `lib/presentation/<feature>/pages/` and `widgets/`.
9. **DI:** Register data sources, repository impl, each use case, and the BLoC factory in [`lib/core/di/feature_module.dart`](lib/core/di/feature_module.dart).
10. **Router:** Register routes in [`lib/core/router/app_router.dart`](lib/core/router/app_router.dart) and names in [`lib/core/router/route_names.dart`](lib/core/router/route_names.dart) if needed.
