# lib

Application source, organized by Clean Architecture layers. Dependencies point
inward: presentation and data depend on domain; only the composition root
(`main.dart` and `.injector/`) knows every layer.

## Contents

| Path | Purpose |
| --- | --- |
| `main.dart` | Entry point: bindings, orientation, `.env`, Firebase (online only), service locator, API and game config, languages, then `AppRoot`. |
| `.config/` | App-wide constants: preference keys, game API URLs, runtime flags. |
| `.injector/` | Composition root. Chooses implementations and wires them with GetIt. |
| `domain/` | Entities, repository interfaces, and use cases. Pure Dart. |
| `data/` | Repository implementations, data sources, models, and mappers. |
| `presentation/` | Screens, widgets, blocs, routing, theme, and localization. |
| `util/` | Logging helpers shared by the app. |

## Runtime modes

- Guest: `--dart-define=GUEST_MODE=true`, read by `.config/runtime.dart`.
  Runs without Firebase or Supabase.
- Online: initializes Firebase from the native configuration files and reads
  Supabase values from `.env`.

See the [project README](../README.md#getting-started) for setup.

## Related

- [Layer boundaries](../docs/architecture.md)
- [.config](.config/README.md), [.injector](.injector/README.md),
  [domain](domain/README.md), [data](data/README.md),
  [presentation](presentation/README.md), [util](util/README.md)
