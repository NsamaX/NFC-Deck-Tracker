# util

Logging helpers shared across the app.

## Contents

| Path | Purpose |
| --- | --- |
| `logger.dart` | `LoggerUtil`: debug-only logging with a message buffer. |
| `domain_logger.dart` | `AppDomainLogger`: adapts `LoggerUtil` to the domain `DomainLogger` port. |

## Rules

- Keep helpers here free of business logic. Domain code logs through the
  `DomainLogger` port, not `LoggerUtil`.

## Related

- [lib](../README.md)
