<h1 align="center">📦 Dependency Injection (Service Locator)</h1>

## Overview

The `.injector/` folder is responsible for setting up **dependency injection (DI)** using the `GetIt` service locator pattern.  
This approach enables centralized, modular, and testable management of dependencies—separating construction logic from usage.

All app dependencies—such as repositories, use cases, Cubits, and services—are registered and resolved through this layer.

---

## ⚙️ Initialization Flow

The entry point for dependency setup is:

```dart
await initServiceLocator();
````

This function orchestrates the registration of all required services in the correct order and ensures everything is ready before launching the application.

---

## 📁 File Structure & Responsibilities

```plaintext
.injector/
├── register_cubit.dart        # Registers Cubits for UI state management
├── register_datasource.dart   # Registers API clients, local, and remote data sources
├── register_repository.dart   # Registers concrete repository implementations
├── register_service.dart      # Registers core services (e.g., Firestore, SQLite, SharedPreferences)
├── register_usecase.dart      # Registers business logic use cases
├── service_locator.dart      # Entry point that wires up all dependencies
```

---

### 🗂️ Detailed File Descriptions

* **`register_cubit.dart`**

  * Registers all Cubits used across the app for state management.
  * Each Cubit usually depends on use cases from the domain layer.

* **`register_datasource.dart`**

  * Registers all data sources (local/remote/API).
  * Maps to the `data/datasource/` layer and handles low-level operations.

* **`register_repository.dart`**

  * Binds domain repository interfaces to concrete data-layer implementations.
  * Acts as a bridge between `data` and `domain` layers.

* **`register_service.dart`**

  * Initializes and registers foundational services such as:

    * SQLite
    * Firestore
    * FirebaseAuth
    * SharedPreferences
    * Route observers, etc.
  * These services are typically required by data sources.

* **`register_usecase.dart`**

  * Registers domain use cases which encapsulate business logic.
  * These are injected into Cubits or other higher-level components.

* **`service_locator.dart`**

  * Central DI entry point; calls all setup functions in the correct sequence.
  * Uses `GetIt` to manage instances and `locator.allReady()` to ensure all async singletons are ready.

---
