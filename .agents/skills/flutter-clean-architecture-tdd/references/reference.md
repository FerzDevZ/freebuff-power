# Flutter Clean Architecture Directory Structure

```
lib/
├── core/
│   ├── error/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   └── network_info.dart
│   └── usecase/
│       └── usecase.dart
└── features/
    └── authentication/
        ├── domain/
        │   ├── entities/
        │   │   └── user.dart
        │   ├── repositories/
        │   │   └── auth_repository.dart
        │   └── usecases/
        │       ├── login_usecase.dart
        │       └── get_current_user_usecase.dart
        ├── data/
        │   ├── datasources/
        │   │   ├── auth_remote_data_source.dart
        │   │   └── auth_local_data_source.dart
        │   ├── models/
        │   │   └── user_model.dart
        │   └── repositories/
        │       └── auth_repository_impl.dart
        └── presentation/
            ├── bloc/
            │   └── auth_bloc.dart
            ├── pages/
            │   └── login_page.dart
            └── widgets/
                └── login_form.dart
```
