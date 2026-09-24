# presentation

Screens, widgets, and UI state. Works with domain entities and use cases only.

`app.dart` receives `PresentationDependencies` from the composition root and
exposes them through `PresentationScope`. Pages create blocs through the typed
factories in that scope.

## Contents

| Path | Purpose |
| --- | --- |
| `app.dart` | `AppRoot`: theme, locale, routing, and the global error banner. |
| `dependencies.dart` | `PresentationDependencies` and `PresentationScope`. |
| `nfc_life_cycle_observer.dart` | Stops the NFC session on route changes and when the app is paused. |
| `constant.dart` | `WidgetConstant`: shared sizes and paddings. |
| `auth/` | Guest entry and navigation helper. |
| `bloc/` | One folder per bloc (`bloc.dart`, `event.dart`, `state.dart`) and `ErrorReporting`. |
| `page/` | Top-level screens, one per route. |
| `route/` | Route names, arguments, and `RouteGenerator`. |
| `theme/` | Colors, text styles, and component themes. |
| `widget/` | Reusable widgets, grouped by feature or role. |
| `locale/` | Translation loading and language switching. |

## Localization

Translation files live in `assets/locale/`, one JSON file per language code.
`LanguageManager` discovers them from the asset manifest, so adding a language
needs no code change. Keys are dotted paths (`common.button_ok`), and each
file needs a `language_name` entry. See [assets](../../assets/README.md).

## Rules

- Never import `data/`, `.injector/`, `main.dart`, `domain/repository/`, or
  infrastructure SDKs.
- Blocs that await a use case mix in `ErrorReporting`; pages show errors
  through `ErrorListener`.

## Related

- [Working guide](../../.claude/guide.md)
