# .injector

Composition root. The only place that chooses concrete implementations and
uses GetIt. `main.dart` calls `initServiceLocator()` at startup.

## Contents

| Path | Purpose |
| --- | --- |
| `locator.dart` | The shared GetIt instance. |
| `service_locator.dart` | `initServiceLocator()`: runs the registrations in order. |
| `register_service.dart` | SDK clients, local services, and Guest offline clients. |
| `register_datasource.dart` | Storage and game API data sources. |
| `register_repository.dart` | Binds domain interfaces to data implementations. |
| `register_usecase.dart` | Use cases with their ports, logger, and settings policy. |
| `register_bloc.dart` | Blocs with their use cases. |
| `presentation_dependencies.dart` | Builds the typed factories and shared blocs for `PresentationScope`. |

Registration order: services, data sources, repositories, use cases, blocs.

## Rules

- Guest and online implementations are selected here, based on
  `.config/runtime.dart`.
- Never import this folder from domain, data, or presentation.

## Related

- [Working guide](../../.claude/guide.md)
