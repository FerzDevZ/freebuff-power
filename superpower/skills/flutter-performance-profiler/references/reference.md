# Flutter Performance Diagnostic Runbook

## 1. DevTools Timeline Investigation
- Run with `--profile` mode: `flutter run --profile --trace-skia`
- Look for **Red Frame Bars** in the DevTools Performance overlay:
  - **UI Thread Spikes**: Indicates heavy Dart execution, excessive widget rebuilding, or unoptimized data transformations in `build()`.
  - **Raster Thread Spikes**: Indicates GPU bottleneck, excessive `saveLayer()` clipping, large image decodes, or un-cached complex custom shaders.

## 2. Common Antipatterns & Fixes
| Antipattern | Fix |
|---|---|
| `Opacity(opacity: 0.5, child: ...)` | Use `Color.withValues(alpha: 0.5)` or `AnimatedOpacity` to avoid `saveLayer()` offscreen buffer |
| Deep widget rebuilds via `setState` | Extract state into local stateful widget or use `BlocSelector` |
| Full-resolution images in list items | Specify `ResizeImage(provider, width: 200, height: 200)` |
