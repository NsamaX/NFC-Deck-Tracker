<h1 align="center">📦 Dependency Injection (Service Locator)</h1>

## Overview

The `.injector/` folder is responsible for setting up **dependency injection (DI)** using the `GetIt` service locator pattern.  
This structure enables the application to manage dependencies in a centralized, modular, and testable manner without relying on manual instantiation or tight coupling.

All app services—including databases, repositories, use cases, and Cubits—are registered and resolved through this layer.

---

## ⚙️ Initialization Flow

The entry point for dependency setup is:

```dart
await setupLocator();
````

This function registers all required services in order and ensures that all are ready before the application starts.

---

## 📁 File Structure & Responsibilities

```plaintext
.injector/
├── setup_cubit.dart              # Registers Cubits for state management
├── setup_database.dart           # Initializes database-related instances
├── setup_datasource.dart         # Registers data source implementations (API, local, remote)
├── setup_firestore.dart          # Sets up Firebase/Firestore dependencies
├── setup_locator.dart            # Entry point to register all dependencies
├── setup_misc.dart               # Miscellaneous utilities (e.g., loggers, config)
├── setup_repository.dart         # Registers repository implementations
├── setup_shared_preferences.dart # Initializes SharedPreferences service
├── setup_sqlite.dart             # Sets up SQLite services and DAOs
├── setup_usecase.dart            # Registers domain use cases
```

---

### 🗂️ Detailed File Descriptions

* **`setup_cubit.dart`**

  * Registers Cubits that manage application state (UI logic).
  * Typically depends on use cases from the domain layer.

* **`setup_database.dart`**

  * General database setup (e.g., creating singletons, configs).
  * Can coordinate multiple storage mechanisms.

* **`setup_datasource.dart`**

  * Registers API clients, local storage managers, or remote sources.
  * Maps to the `data/datasource/` layer.

* **`setup_firestore.dart`**

  * Initializes and registers Firebase or Firestore-related services.
  * Can include Firestore instance, authentication, or Firebase-specific helpers.

* **`setup_misc.dart`**

  * Registers other utilities such as loggers, debuggers, or configs.
  * Use this file for tools not tied to a specific layer.

* **`setup_locator.dart`**

  * The main file that calls each setup function in the proper order.
  * Uses `GetIt` to globally register dependencies.
  * Ensures all services are ready before the app starts via `await locator.allReady()`.

* **`setup_repository.dart`**

  * Binds interface contracts to their concrete repository implementations.
  * Bridges the domain and data layers.

* **`setup_shared_preferences.dart`**

  * Initializes and registers access to SharedPreferences storage.
  * Useful for storing settings, tokens, etc.

* **`setup_sqlite.dart`**

  * Prepares SQLite services, DAOs, or related helpers.
  * Should be used before registering repositories that depend on local storage.

* **`setup_usecase.dart`**

  * Registers domain use cases which contain core business logic.
  * These are later injected into Cubits or other parts of the app.

---
