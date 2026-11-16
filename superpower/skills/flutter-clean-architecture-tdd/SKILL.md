---
name: flutter-clean-architecture-tdd
description: >-
  Design and implement Flutter Clean Architecture with Domain-Driven Design (Entities, UseCases, Repositories),
  fpdart/dartz functional error handling, and Mocktail TDD.
  Use when structuring enterprise Flutter codebases, writing unit/golden tests, or decoupling business logic.
---

# Flutter Clean Architecture & TDD Master

This skill enforces strict Clean Architecture and Test-Driven Development (TDD) for Flutter applications, isolating core domain logic from UI frameworks, database engines, and third-party APIs.

---

## 🏛️ Clean Architecture Layer Dependency Rule

```mermaid
graph TD
    UI[Presentation Layer: Pages, Widgets, BLoC / Riverpod] --> UseCase[Domain Layer: Use Cases & Interactors]
    UseCase --> Entity[Domain Layer: Pure Entities & Failures]
    DataRepo[Data Layer: Repository Implementations] --> UseCase
    DataRepo --> RemoteDS[Data Source: Dio Remote API]
    DataRepo --> LocalDS[Data Source: Drift / SQLite Local Cache]
    
    style Entity fill:#22c55e,color:#fff
    style UseCase fill:#3b82f6,color:#fff
    style DataRepo fill:#eab308,color:#fff
    style UI fill:#ec4899,color:#fff
```

*The Dependency Rule: Dependencies point ONLY inwards toward the Domain.*

---

## 🎯 Production Invariants

1. **Domain Isolation**: The `domain/` directory must NEVER import Flutter UI packages (`package:flutter/*`) or data-layer packages (`dio`, `sqflite`). Pure Dart only.
2. **Functional Error Handling**: Never throw unhandled exceptions across architectural boundaries. Return `Either<Failure, T>` (via `fpdart`).
3. **Repository Contract Inversion**: Define repository interfaces in `domain/repositories/` and implement them in `data/repositories/`.
4. **TDD Coverage**: Every Use Case and Repository must have unit test coverage using `mocktail` or `mockito` before reaching production.

---

## 📋 Prosedur Eksekusi

1. **Panduan Struktur Folder DDD**:
   - Rujuk [references/clean-arch-structure.md](./references/clean-arch-structure.md).
2. **Template UseCase & Repository**:
   - Rujuk template di [resources/usecase-template.dart](./resources/usecase-template.dart).
3. **Verifikasi Boundary Layer**:
   - Jalankan `bash scripts/verify-clean-arch.sh`.
