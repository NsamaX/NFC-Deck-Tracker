# Domain layer

Pure Dart application logic. Imports only other domain files and the pure Dart
packages `equatable` and `uuid`.

- `entity/`: values exchanged by use cases and repository contracts.
- `repository/`: interfaces grouped by responsibility.
- `usecase/`: application workflows called by presentation.
- `service/`: logging port with a silent default for isolated tests.
- `value/`: domain enums such as `PlayerAction`.

Persistence models, JSON, SDK types, and mappers belong in data. Use cases accept
interfaces through constructors and never resolve dependencies through GetIt.
See [architecture](../../docs/architecture.md).
