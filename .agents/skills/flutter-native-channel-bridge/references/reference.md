# Pigeon Type-Safe Platform Channel Guide

## 1. Pigeon Definition File (e.g. `pigeons/messages.dart`)
```dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/native_bridge.g.dart',
  kotlinOut: 'android/app/src/main/kotlin/com/example/NativeBridge.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.example'),
  swiftOut: 'ios/Runner/NativeBridge.g.swift',
))
class NativeUserPayload {
  String? id;
  String? email;
}

@HostApi()
abstract class NativeAuthApi {
  @async
  NativeUserPayload authenticateBiometric(String prompt);
}
```

## 2. Compile Pigeon
```bash
dart run pigeon --input pigeons/messages.dart
```
