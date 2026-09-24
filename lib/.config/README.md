# .config

App-wide constants and runtime flags, loaded once at startup by `main.dart`.

## Contents

| Path | Purpose |
| --- | --- |
| `app.dart` | `AppConfig`: SharedPreferences keys. |
| `runtime.dart` | `RuntimeConfig.guestMode`, set with `--dart-define=GUEST_MODE=true`. |
| `game.dart` | `GameConfig`: game IDs, base URL per environment, available games, and icon paths. |
| `api.dart` | `ApiConfig`: base URL lookup and catalog batch size for the active environment. |

The environment is `production` in release builds and `development` otherwise.
A game is available only when it has a non-empty URL in that environment.

## Adding a game

1. `game.dart`: add a game ID constant and its base URL under each
   environment.
2. `data/datasource/api/`: add `<game>.dart` with a `GameApi` implementation
   (`fetch`, `find`) and a `PagingStrategy` implementation (`buildPage`).
   Use `pokemon.dart` as the reference.
3. `data/datasource/api/service_factory.dart`: register the game in
   `_apiRegistry` and `_pagingRegistry`.
4. `assets/image/game/<game>.png`: add the game icon, named after the game ID.

## Related

- [data](../data/README.md)
- [assets](../../assets/README.md)
