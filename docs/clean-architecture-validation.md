# Clean architecture validation (baseline)

For full project context for tools and contributors, see [`ai-knowledge-base.md`](ai-knowledge-base.md).

This document records layering findings as of the use-case rollout. It is a baseline for future refactors, not a full audit.

## Aligned with clean architecture

- **Layer folders:** `data/`, `domain/`, `presentation/` separate concerns.
- **Repositories** abstract remote/local IO; **data sources** are used only inside repository implementations.
- **Dependency injection** for features lives in [`lib/core/di/feature_module.dart`](../lib/core/di/feature_module.dart).

## Known violations / technical debt

| Issue | Notes |
|--------|--------|
| **Domain imports `data/`** | Some repository contracts expose DTOs (e.g. schedule, asset, notification, timesheet). Domain should ideally expose only entities or domain-specific types. |
| **Presentation imports `data/`** | Some UI/bloc code references data models (e.g. schedule flow). Prefer mapping to presentation models or domain entities at the boundary. |
| **Use cases return data-layer types** | Thin use cases still leak DTOs until repositories are refactored. |
| **App shell** | Theme persistence uses domain port [`ThemePreferenceRepository`](../lib/domain/app/repositories/theme_preference_repository.dart) and [`GetSavedThemeModeUsecase`](../lib/domain/app/usecases/get_saved_theme_mode_usecase.dart) / [`PersistThemeModeUsecase`](../lib/domain/app/usecases/persist_theme_mode_usecase.dart) instead of calling [`LocalCacheService`](../lib/core/storage/local_cache_service.dart) from [`AppBloc`](../lib/presentation/app/bloc/app_bloc.dart). |

## Follow-up epic (recommended)

- Introduce domain DTOs/entities at repository interfaces so use cases and presentation do not depend on `data/`.
- Align `TimeSheetResponse` entity with repository return types where models duplicate domain shapes.
