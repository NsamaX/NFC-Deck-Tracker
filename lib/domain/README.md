# domain

Pure Dart application logic. Imports only other domain files and the packages
`equatable` and `uuid`.

## Contents

| Path | Purpose |
| --- | --- |
| `entity/` | Values exchanged by use cases and repository contracts. |
| `repository/` | Repository interfaces (ports), grouped by aggregate. |
| `usecase/` | Application workflows called by presentation, one rule per use case. |
| `service/` | Clock, ID generator, logger port, and offline-first `sync_policy.dart`. |
| `value/` | Domain enums and failure types such as `PlayerAction`. |

## Rules

- No Flutter, SDK, app configuration, data model, mapper, or GetIt imports.
- Use cases receive interfaces through constructors.
- Persistence models, JSON, and mappers belong in `data/`.
- Record new ports, use cases, and entities in `.claude/registry.md`.

## Related

- [Layer boundaries](../../docs/architecture.md)
- [data](../data/README.md)
