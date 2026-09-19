# Composition root

Only this layer chooses concrete implementations and uses GetIt. `main.dart`
bootstraps configuration and calls `initServiceLocator()`.

Registration order: services → data sources → repositories → use cases → blocs.

- `register_service.dart`: SDK clients/local services and Guest offline clients.
- `register_datasource.dart`: storage and game API operations.
- `register_repository.dart`: binds domain interfaces to data implementations.
- `register_usecase.dart`: injects ports, logging, and settings policy.
- `register_bloc.dart`: injects use cases into presentation state holders.
- `presentation_dependencies.dart`: supplies typed UI factories/shared blocs.

`PresentationScope` exposes typed dependencies to views. Do not import this
folder into domain, data, or presentation. See
[architecture](../../docs/architecture.md).
