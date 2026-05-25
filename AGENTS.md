# Teman Isyarat — Agent Guide

## Quick Facts

- **What**: Flutter app for real-time Indonesian Sign Language (BISINDO) translation using MediaPipe hand/pose landmarks + custom TFLite classification model.
- **Structure**: Monolithic Flutter project (no feature modules). All Dart source in `lib/`. Android native layer in `android/`. TFLite inference and landmark processing run on the Android (Kotlin) side, not Dart.
- **State**: `StatefulWidget.setState()` on main pages; `TranslateController` (extends `ChangeNotifier`) + `addListener` for translate screen.
- **DI**: None — dependencies created inline.
- **Networking**: None — fully offline, on-device inference.
- **Persistence**: Simple file I/O (`history.txt` via `path_provider`).

## Tool Versions (`.tool-versions`)

| Tool | Version |
|------|---------|
| Flutter | `3.41.9` |
| Kotlin | `2.3.21` |
| Gradle | `9.5.1` |
| Java | `openjdk-26` |
| FlutterGen | `5.14.1` |

## Source Layout

```
lib/
  main.dart                           # App entry + ALL widgets: MainPage, HomePage,
                                      #   CustomAppBar, CustomNavigationBar, Section2,
                                      #   Section5, ListItemWidget, SectionHeader,
                                      #   PlaceholderPage, ArtikelPage, DetailArtikel,
                                      #   SettingsPage (545 lines)
  pages/
    translate/
      translate_page.dart             # Camera + sign translation UI (362 lines)
      translate_controller.dart       # MethodChannel bridge + prediction state +
                                      #   buffer state + history persistence (129 lines)
      widgets/
        scanning_dots.dart            # Animated scanning indicator (55 lines)
  services/
    history_service.dart              # Read/write history.txt via path_provider (27 lines)

android/app/src/main/kotlin/com/example/android/
  MainActivity.kt                     # FlutterActivity
  handlandmarker/
    HandLandmarkerPlugin.kt           # Flutter plugin registration (PlatformViewFactory)
    HandLandmarkerView.kt             # PlatformView: CameraX + overlay + TFLite inference
                                      #   + landmark assembly + circular buffer + prediction
                                      #   processing + temporal smoothing (ALL in one file)
    HandLandmarkerHelper.kt           # MediaPipe Hand/Pose Landmarker wrapper
    HandLandmarkerOverlay.kt          # Canvas skeleton overlay

android/app/src/main/kotlin/com/example/temanisyarat/
  (empty — merge artifact removed)
```

## Data Flow

```
Android CameraX (PlatformView)
  -> HandLandmarkerHelper (MediaPipe hand + pose)
  -> HandLandmarkerView.onResults()
    -> assembleFrame()                  # 51 landmarks x 3 = 153-dim
    -> frameBuffer (circular)           # 125-frame native FloatArray buffer
    -> TFLite Interpreter.run()         # [1,125,153] -> [1,20]
    -> Softmax + temporal smoothing     # majority vote over 15-frame history
  -> MethodChannel 'temanisyarat/hand_landmarker_$id' (onLandmarks callback)
  -> TranslateController._handleLandmarks()
    -> update bufferCount, bufferReady, writeOffset, totalFrames, prediction
    -> notifyListeners()
  -> TranslatePage (setState on listener callback)
    -> UI update
```

## Key Architecture Details

- **Input shape**: `[1, 125, 153]` — 125 frames, each with 51 landmarks (9 pose + 21 left hand + 21 right hand) × 3 (x,y,z).
- **Output shape**: `[1, 20]` — logits for 20 sign classes.
- **Classes**: `aku, apel, ayah, besok, buku, dia, dua, hari ini, ibu, kamu, kuning, maaf, merah, nama, pisang, salam, satu, teman, terima kasih, tiga`.
- **Temporal smoothing**: 15-frame history, 60% majority threshold.
- **Confidence threshold**: 0.8 (softmax probability).
- **Early inference**: Starts predicting after 30 frames (instead of 125) via `EARLY_INFERENCE_FRAMES`.
- **Inference interval**: Runs inference every 2 frame callbacks (`INFERENCE_INTERVAL`).
- **XNNPACK**: Enabled via `setUseXNNPACK(true)` on the TFLite Interpreter.
- **Model file**: `android/app/src/main/assets/models/model_raw.tflite` — loaded via Android `Interpreter` (NOT `tflite_flutter`), copied from assets to `context.cacheDir` on first launch.
- **Pose indices used**: `[0, 11, 12, 13, 14, 15, 16, 23, 24]` (nose, shoulders, elbows, wrists, hips).
- **Missing landmarks**: encoded as `NaN` (Float.NaN) in the feature vector.
- **PlatformView ID**: `temanisyarat/hand_landmarker` (registered in `HandLandmarkerPlugin`). Method channel: `temanisyarat/hand_landmarker_$id` (appended with view ID).
- **All inference code** (assemble, buffer, predict, softmax, smoothing) lives in `HandLandmarkerView.kt` — the Dart side is a thin UI shell + state relay via `TranslateController`.

## Conventions

- **Code style**: `package:flutter_lints/flutter.yaml` (default Flutter lints). No custom rules.
- **Naming**: Classes are PascalCase, files are snake_case. Widgets use `Widget` suffix inconsistently.
- **Keys**: All widgets use `super.key` constructor pattern.
- **Imports**: Relative paths (e.g., `'pages/...'`).
- **Android**: Kotlin, `com.android.application` + `kotlin-android` plugins, compileSdk/ndkVersion from Flutter Gradle plugin, minSdk 24, Java 17 target.
- **No comments** in source code (doc comments, inline comments are absent).
- **No tests** covering actual app logic — the only test (`test/widget_test.dart`) is the unused Flutter counter template.

## Routes

| Path | Trigger | Widget | File |
|------|---------|--------|------|
| `/` | App start | `MainPage` (bottom nav: Home/Belajar/Artikel) | `lib/main.dart` |
| Translate | Home page "Mulai Terjemahkan" button | `TranslatePage` | `lib/pages/translate/translate_page.dart` |
| Artikel | Artikel page list item tap | `DetailArtikel` | `lib/main.dart` |
| Settings | `CustomAppBar` menu icon (top-right) | `SettingsPage` | `lib/main.dart` |

## Dependencies (pubspec.yaml)

- `cupertino_icons: ^1.0.8` — iOS-style icons
- `permission_handler: ^11.4.0` — camera permission
- `path_provider: ^2.1.5` — file paths
- `flutter_launcher_icons: ^0.13.1` (dev) — icon generation
- `flutter_lints: ^6.0.0` (dev) — lint rules

Note: `tflite_flutter` is NOT used — TFLite inference runs on the native Android side via `org.tensorflow:tensorflow-lite`.

## Android Dependencies (build.gradle.kts)

- `androidx.camera:camera-*:1.4.2` — CameraX
- `com.google.mediapipe:tasks-vision:0.10.29` — MediaPipe Hand/Pose Landmarker (model files: `hand_landmarker.task`, `pose_landmarker_lite.task` in `android/app/src/main/assets/`)
- `org.tensorflow:tensorflow-lite:2.14.0` — TFLite runtime
- `org.tensorflow:tensorflow-lite-select-tf-ops:2.14.0`

## Known Issues / Gaps

- No CI/CD pipeline.
- Release signing uses debug config.
- AndroidManifest namespace (`com.example.android`) doesn't match app ID (`com.temanisyarat.android`).
- `com.example.temanisyarat/` package is now empty (merge artifact removed).
- `test/widget_test.dart` still contains the default Flutter counter template test (not updated for current app).
- No `settings.gradle.kts` at Flutter project root — Android settings live inside `android/` subdirectory.

## How to Run

```bash
flutter run                          # default device
flutter run -d <device-id>          # specific device
flutter build apk                    # Android release build
flutter build ios                    # iOS release build
flutter analyze                      # lint check
flutter test                         # run tests
flutter pub get                      # install deps
```

## Common Tasks

- **Add new sign class**: Update `CLASS_LABELS` in `HandLandmarkerView.kt` (companion object), retrain model, replace `android/app/src/main/assets/models/model_raw.tflite`.
- **Add new page/screen**: Add widget to `main.dart` or new file under `lib/pages/`, use `Navigator.push`.
- **Modify landmark selection**: Edit `poseIndices` in `HandLandmarkerView.kt` `assembleFrame()` and adjust `FRAME_DIM` constant.
- **Change buffer size**: Change `MAX_FRAMES` (125) in `HandLandmarkerView.kt` companion object.
- **Tune smoothing**: Change `HISTORY_SIZE` (15) and `MAJORITY_THRESHOLD` (0.6) in `HandLandmarkerView.kt` companion object.
- **Tune confidence**: Change `CONFIDENCE_THRESHOLD` (0.8) in `HandLandmarkerView.kt` companion object.
- **Modify UI prediction state**: Edit `TranslateController` in `lib/pages/translate/translate_controller.dart`.
