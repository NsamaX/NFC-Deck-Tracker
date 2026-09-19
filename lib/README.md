<h1 align="center">📦 Application Source (`lib/`)</h1>

## Overview

The `lib/` directory contains the **entire application source code**, structured using the **Clean Architecture** pattern.
This structure separates the app into distinct layers to ensure **modularity**, **testability**, and **maintainability**.
Each layer has a clear responsibility and communicates with other layers through well-defined interfaces.

---

## 🧱 Clean Architecture Layers

1. **Presentation Layer** – UI, interaction, and state management
2. **Domain Layer**       – Core business logic and use cases
3. **Data Layer**         – Data access from APIs, databases, etc.
4. **Injection Layer**    – Dependency registration via service locator
5. **Config Layer**       – App-wide constants and configurations

---

## 📁 Folder Structure & Responsibilities

```plaintext
lib/
├── .config/                     # App-wide constants and configurations
├── .injector/                   # Dependency injection setup (via GetIt)
├── data/                        # Data sources, models, and repository implementations
├── domain/                      # Business logic, use cases, and entities
├── presentation/                # UI components, localization, theming, and Blocs
├── util/                        # Reusable utilities (e.g., logger, extensions, helpers)
├── main.dart                    # App entry point and bootstrap logic
├── presentation/app.dart       # App UI and NFC lifecycle composition
```

---

## 🗂️ Detailed Folder Descriptions

### **`.config/`**

  * **Purpose**: Defines static constants used throughout the app, such as game identifiers, environment configurations, and base URLs.

---

### **`.injector/`**

  * **Purpose**: Sets up dependency injection using `GetIt` for managing the application's dependencies.
  * 📄 [See more](.injector/README.md)

---

### **`data/`**

  * **Purpose**: Handles all data-related operations, including interacting with external APIs, local storage, and cloud services.
  * 📄 [See more](./data/README.md)

---

### **`domain/`**

  * **Purpose**: Contains application rules, entities, repository interfaces, and use cases. Persistence mappers live in `data/mapper`.
  * 📄 [See more](./domain/README.md)

---

### **`presentation/`**

  * **Purpose**: Manages UI rendering, application state, localization, navigation, and theming.
  * 📄 [See more](./presentation/README.md)

---

### **`util/`**

  * **Purpose**: Provides general-purpose helper functions and services for common tasks across the application.

---

### **Guest and online configuration**

  * `.config/runtime.dart` selects Guest mode with `--dart-define=GUEST_MODE=true`.
  * Online mobile builds initialize Firebase from the native platform configuration files.

---

### **`main.dart`**

  * Entry point of the application. It initializes essential bindings, sets device orientation, loads environment variables, runs dependency injection setup, and starts the main application widget.

---

## ⚠️ Development Notes

Guest builds run without Firebase or Supabase credentials. Online builds need
the native Firebase configuration and Supabase values in `.env`. See the
[project README](../README.md#local-configuration) for the current emulator setup.

> ℹ️ This documentation provides guidance to developers contributing to the app’s core structure, ensuring a consistent and understandable codebase.

---
