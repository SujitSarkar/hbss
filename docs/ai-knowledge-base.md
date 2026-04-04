# AI knowledge base — Maori Health (`maori_health`)

Persistent reference for coding agents and contributors. **Package name:** `maori_health` (import prefix). **SDK:** Dart ^3.11, Flutter via **FVM** (see repo README).

---

## 1. Architecture

| Layer | Path | Contains |
|-------|------|----------|
| Presentation | `lib/presentation/` | Pages, widgets, **BLoC** (events/states/bloc) |
| Domain | `lib/domain/` | Entities, **repository interfaces**, **use cases** |
| Data | `lib/data/` | **Remote/local data sources**, JSON **models**, **repository implementations** |
| Core | `lib/core/` | DI modules, Dio, routing, storage, theme, errors, `Result` type |

**Dependency direction (strict):**

```text
BLoC → use case → repository (abstract) ← repository impl → data source(s)
```

- **Never** inject data sources into BLoCs. Register data sources only for `*RepositoryImpl` in [`lib/core/di/feature_module.dart`](../lib/core/di/feature_module.dart).
- **BLoCs take use cases** (or a single use case per action), not repositories—same pattern as `ScheduleBloc`, `AuthBloc`, etc.
- Use cases are thin classes with a `call(...)` method and constructor-injected repository; name suffix **`Usecase`** (e.g. `GetClientsUsecase`).

---

## 2. Dependency injection

- Global `GetIt` instance: [`lib/core/di/injection.dart`](../lib/core/di/injection.dart) (`getIt`).
- Registration order: **`registerServiceModule`** → **`registerNetworkModule`** → **`registerFeatureModule`** (see `registerDependencies()`).
- Feature wiring: **[`lib/core/di/feature_module.dart`](../lib/core/di/feature_module.dart)** — per feature: data sources → repository impl → use cases (`registerLazySingleton` is common) → `registerFactory` for BLoC.

---

## 3. Cross-cutting libraries

| Concern | Packages / location |
|---------|---------------------|
| State | `flutter_bloc`, `equatable` |
| DI | `get_it` |
| HTTP | `dio` (see `core/network/dio_client.dart`) |
| Routing | `go_router` — [`lib/core/router/app_router.dart`](../lib/core/router/app_router.dart), [`route_names.dart`](../lib/core/router/route_names.dart) |
| Secure + prefs | `flutter_secure_storage`, `shared_preferences` via core services |
| Images | `cached_network_image` |

---

## 4. Configuration and entrypoints

| Flavor | Entry | Notes |
|--------|--------|--------|
| Dev | `lib/main_dev.dart` | Uses dev base URL from [`EnvConfig`](../lib/core/config/env_config.dart) |
| Prod | `lib/main_prod.dart` | Production URL |
| Shared bootstrap | [`lib/main_common.dart`](../lib/main_common.dart) | `registerDependencies()`, `runApp(App())` |

Run locally (use **FVM**): `fvm flutter run --flavor dev -t lib/main_dev.dart`

---

## 5. Error and result handling

- Domain/API failures use types under [`lib/core/error/`](../lib/core/error/).
- Async operations return **`Result<AppError, T>`** from [`lib/core/result/`](../lib/core/result/) where applicable; BLoCs typically `fold` on failure vs success.

---

## 6. Feature module map (examples)

| Area | Domain path | Presentation path |
|------|-------------|-------------------|
| Auth | `lib/domain/auth/` | `lib/presentation/auth/` |
| Schedule | `lib/domain/schedule/` | `lib/presentation/schedule/` |
| Dashboard | `lib/domain/dashboard/` | `lib/presentation/dashboard/` |
| App theme | `lib/domain/app/` (e.g. `ThemePreferenceRepository`) | `lib/presentation/app/` (`AppBloc`) |

Not every screen has a matching `domain/<name>/`; some are UI-only (e.g. settings shell) or share `lookup_enums` / `app_settings`.

---

## 7. Layering debt (do not “fix” unless asked)

Baseline notes: [`clean-architecture-validation.md`](clean-architecture-validation.md). Some repository interfaces still expose **data-layer DTOs**; new work should prefer domain types at boundaries when touching those APIs.

---

## 8. Commands (FVM)

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter build apk --flavor dev -t lib/main_dev.dart
```

---

## 9. Conventions for new features

1. Add/update **domain** repository interface and entities.
2. Add **use cases** (one per user-facing action).
3. Implement **data source** + **models** + **repository impl**.
4. Add **BLoC** that depends **only on use cases**.
5. Register in **`feature_module.dart`**; add routes if needed.

See also the **Adding a New Feature** section in the [project README](../README.md).
