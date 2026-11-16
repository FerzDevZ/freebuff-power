# Flutter Web Production Reference

## 1. Modern Web Build Commands
```bash
# WebAssembly build (Requires Chrome 119+, Firefox 120+, Safari 18.2+)
flutter build web --wasm --release

# Fallback CanvasKit build
flutter build web --release --web-renderer canvaskit
```

## 2. Removing the Hash `#` from URLs
In `lib/main.dart`:
```dart
import 'package:flutter_web_plugins/url_strategy.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}
```
