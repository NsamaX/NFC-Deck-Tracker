# Project instructions

Claude Code works in this checkout with the project owner. Commit only when the
owner asks. Communicate with the owner in Thai; write code, commit messages, and
documents in concise English. No comments that restate the code, no emoji.

This is a Flutter thesis app being rebuilt for maintainability. Keep the
existing Clean Architecture layering and the existing UX/UI; do not reorganize
into feature folders or change screens unless asked.

## Before a task

1. Read `README.md` and `docs/architecture.md` (layer rules, where to change
   code, deferred behavior findings).
2. Inspect `git status --short` and identify the layer and files involved.
3. Read the applicable source below before editing.

| Work | Required source |
| --- | --- |
| Adding or changing a port, use case, or entity | `.claude/registry.md` (then update it; `dart run tool/verify_registry.dart` checks it) |
| Cross-layer imports, new dependencies between files | `.obsidian-graph/.VIOLATIONS.md` after `dart run tool/graph.dart` |
| Wiring, Guest vs online implementations | `lib/.injector/` and `lib/.config/runtime.dart` |
| SQL, JSON, Firestore or Supabase format | `lib/data/datasource/`, `lib/data/model/`, `lib/data/mapper/` |
| Screens, widgets, blocs | `lib/presentation/`, entities and use cases from the registry only |
| Translations | `assets/locale/`, `lib/presentation/locale/` |

Rules the tools enforce: domain imports only domain plus `equatable`/`uuid`;
presentation never imports data, `.injector`, `main.dart`, `domain/repository`,
or infrastructure SDKs; data never imports presentation or composition; no
import cycles. `test/architecture_test.dart` enforces the same rules in the
test run and is the rule of record if the two disagree.

## Commands and completion

- `dart run tool/graph.dart` — regenerate `.obsidian-graph/` (one note per
  file, `.VIOLATIONS.md`, `.GRAPH-CONTEXT.md`). Open the folder as an Obsidian
  vault to see the graph. `--check` exits non-zero on violations.
- `dart run tool/verify_registry.dart` — registry vs code.
- `dart run tool/verify.dart` — graph check, registry, and `dart analyze`.
- Tests and builds need the Android environment on this machine:
  `. .\scripts\android-env.ps1` then
  `flutter test --no-pub --dart-define=GUEST_MODE=true`. Guest mode runs
  without Firebase or Supabase; see README for the emulator script.
- Run `dart run tool/verify.dart` and the tests after changes. If a check
  cannot run, say which one and why. Report the diff, checks, and what remains.
- Never print values from `.env`. Never commit `google-services.json` or
  keystores.
