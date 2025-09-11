<h1 align="center">📦 Data Layer</h1>

## Overview

The `data/` layer is responsible for managing all **data sources** and providing structured, reliable data to the rest of the application—typically through repository implementations.  
This layer deals directly with **external APIs, local storage (e.g., SQLite, SharedPreferences), and remote services (e.g., Firebase)**. It also handles model transformations and serialization.

---

## 📁 Folder Structure & Responsibilities

```plaintext
data/
├── datasource/   # Interfaces to different data sources
│   ├── api/      # External API providers (e.g., REST, GraphQL)
│   ├── local/    # On-device storage (e.g., SQLite, SharedPreferences)
│   └── remote/   # Cloud-based sources (e.g., Firebase, Firestore)
├── model/        # Data Transfer Objects (DTOs) and JSON-mappable models
├── repository/   # Implements domain repositories and coordinates data access
```

---

### 🗂️ Detailed Folder Descriptions

* **`datasource/`**

  * Groups the logic for fetching or persisting data from different sources.

  * Each subfolder represents a type of data source:

  - **`api/`**

    * Interfaces with external services via RESTful APIs or other protocols.
    * Handles request construction, response parsing, and network error handling.

  - **`local/`**

    * Manages data stored locally on the device, such as in SQLite databases or `SharedPreferences`.
    * Useful for caching, offline support, or persistent settings.

  - **`remote/`**

    * Interacts with cloud services, primarily Firebase/Firestore.
    * Often handles user-based or realtime-synced data.

* **`model/`**

  * Contains data models or DTOs (Data Transfer Objects) that mirror data structures from external sources.
  * Includes JSON serialization (`fromJson`, `toJson`) and conversion to/from domain entities via mappers.
  * These models are not used directly in the UI.

* **`repository/`**

  * Provides concrete implementations of repository interfaces defined in the `domain` layer.
  * Responsible for:

    * Coordinating between multiple data sources (local, remote, etc.).
    * Mapping data models to domain entities.
    * Error handling, retries, or caching.

---
