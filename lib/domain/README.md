<h1 align="center">📦 Domain Layer</h1>

## Overview

The `domain/` layer encapsulates the **core business logic** of the application.  
It is completely **independent from any external libraries, frameworks, or platforms**, making it highly reusable, modular, and testable.  
This layer defines **entities, business rules (use cases), and data mappers** which are consumed by other layers like data and presentation.

---

## 📁 Folder Structure & Responsibilities

```plaintext
domain/
├── entity/     # Core business entities (pure Dart classes)
├── mapper/     # Converters between data models and domain entities
├── usecase/    # Business logic and application-specific actions
````

---

### 🗂️ Detailed Folder Descriptions

* **`entity/`**

  * Contains domain-level entity classes.
  * Entities represent **core business models** and are free from implementation details like database structure or API response formats.

* **`mapper/`**

  * Contains mapping logic between **data models (DTOs)** and **domain entities**.
  * Ensures a clean separation between domain rules and external representations.

* **`usecase/`**

  * Defines **application-specific business rules** and actions.
  * Each file typically represents a single use case, following the **Command Pattern**.
  * Use cases are invoked by the presentation layer (e.g., Cubits) to perform domain logic like "fetch cards", "save collection", etc.

---
