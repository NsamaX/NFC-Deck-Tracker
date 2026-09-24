# Project instructions

Claude Code works in this checkout with the project owner. Commit only when the
owner asks. Communicate with the owner in Thai; write code, commit messages, and
documents in concise English. No comments that restate the code, no emoji.

This is a Flutter thesis app being rebuilt for maintainability. Keep the
existing Clean Architecture layering and the existing UX/UI; do not reorganize
into feature folders or change screens unless asked.

## Before a task

1. Inspect `git status --short` and identify the layer and files involved.
2. Read the source for the work below. `.claude/guide.md` is the working
   guide; read only the section named, not the whole file.

| Work | Read first |
| --- | --- |
| Adding or changing a port, use case, or entity | `.claude/registry.md` (then update it; `dart run tool/verify_registry.dart` checks it) and guide "Recipes" |
| Cross-layer imports, new dependencies between files | `.obsidian-graph/.VIOLATIONS.md` after `dart run tool/graph.dart`; guide "Rules" |
| Unsure which layer a change belongs to | guide "Where to start" |
| Wiring, Guest vs online implementations | `lib/.injector/`, `lib/.config/runtime.dart` |
| SQL, JSON, Firestore or Supabase format, sync | `lib/data/datasource/`, `lib/data/model/`, `lib/data/mapper/`; guide "Data rules" |
| Screens, widgets, blocs | `lib/presentation/`, entities and use cases from the registry only; guide "Add a bloc or page" |
| Translations | `assets/locale/`, `lib/presentation/locale/` |
| Writing tests | guide "Testing" |

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
