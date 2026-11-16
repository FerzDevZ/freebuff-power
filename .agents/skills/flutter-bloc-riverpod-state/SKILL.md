---
name: flutter-bloc-riverpod-state
description: >-
  Architect production Flutter applications using BLoC pattern (v8.1+) and Riverpod 2.0+ (Notifier, AsyncNotifier),
  Freezed immutable states, and atomic selectors.
  Use when designing state management, refactoring complex UI reactivity, or debugging state transitions in Flutter.
---

# Flutter BLoC & Riverpod State Master

This skill provides industry standards for scalable state management in Flutter applications, mastering both the **BLoC (Business Logic Component)** and **Riverpod 2.0+** architectures.

---

## 🏛️ State Flow & Architecture

```mermaid
graph TD
    UserAction[User Interaction / Event] --> Dispatcher{Pattern}
    
    subgraph BLoC Pattern
        Dispatcher -->|Add Event| Bloc[Bloc / Cubit]
        Bloc -->|Transform / Business Logic| StateEmitter[Emit New Freezed State]
        StateEmitter -->|BlocBuilder / BlocSelector| UI_Bloc[Granular UI Rebuild]
    end

    subgraph Riverpod 2.0+ Pattern
        Dispatcher -->|Call Method| Notifier[Notifier / AsyncNotifier]
        Notifier -->|Update state = AsyncData| StateNotifier[Immutable State Broadcast]
        StateNotifier -->|ref.watch(provider.select)| UI_Riverpod[Targeted Widget Rebuild]
    end
```

---

## 🎯 Production Invariants

1. **Immutable States Always**: Every state class must be immutable using `@freezed` with copyWith support and union cases (`Initial`, `Loading`, `Success`, `Failure`).
2. **Selective Rebuilds**:
   - In BLoC: Never wrap high-level widgets with broad `BlocBuilder`. Always use `BlocSelector` or precise `buildWhen` conditions.
   - In Riverpod: Never `ref.watch(entireProvider)` if only one property is needed; use `ref.watch(provider.select((s) => s.item))`.
3. **Deterministic Side Effects**: Handle one-off navigation, snackbars, and dialogs using `BlocListener` / `ref.listen()`. Never trigger side effects inside widget `build()` methods.
4. **Isolate Long Computations**: Never parse giant JSON or run cryptography inside BLoC/Notifier event handlers directly on the UI isolate; dispatch to `compute()` or `Isolate.run()`.

---

## 📋 Prosedur Eksekusi

1. **Arsitektur BLoC & Riverpod**:
   - Baca panduan mendalam di [references/state-patterns.md](./references/state-patterns.md).
2. **Template BLoC & Notifier**:
   - Rujuk implementasi standar di [resources/bloc-template.dart](./resources/bloc-template.dart).
3. **Audit Transisi State**:
   - Jalankan `bash scripts/audit-state-deps.sh`.
