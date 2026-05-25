# Teman Isyarat — Android App

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter)](https://flutter.dev)
[![Kotlin](https://img.shields.io/badge/Kotlin-2.3-7F52FF?logo=kotlin)](https://kotlinlang.org)
[![MediaPipe](https://img.shields.io/badge/MediaPipe-Tasks--Vision-00BCD4)](https://developers.google.com/mediapipe)
[![TensorFlow Lite](https://img.shields.io/badge/TFLite-2.14-FF6F00?logo=tensorflow)](https://www.tensorflow.org/lite)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

> **Teman Isyarat** (Indonesian for "Sign Friend") is an on-device, real-time Indonesian Sign Language (BISINDO) recognition app built with Flutter and Kotlin. It captures hand and pose landmarks via CameraX and MediaPipe, runs inference through a custom TFLite model, and displays predictions — all fully offline.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Building](#building)
- [Project Ecosystem](#project-ecosystem)
- [License](#license)

---

## Overview

The app is the mobile endpoint of a three-part system:

1. **`lm/`** — MediaPipe landmark extraction pipeline from raw video
2. **`model/`** — GRU-based neural network training & TFLite export
3. **`android/`** (this repo) — Flutter app wrapping the exported TFLite model for on-device inference

It recognizes **20 BISINDO vocabulary words** (Central Java dialect) through live camera feed, without requiring internet connectivity.

| Category     | Words                                                                     |
| ------------ | ------------------------------------------------------------------------- |
| **Pronouns** | Aku, Kamu, Dia                                                            |
| **Common**   | Salam, Terima Kasih, Maaf, Nama                                           |
| **Time**     | Hari Ini, Besok                                                           |
| **Color**    | Merah, Kuning                                                             |
| **Family**   | Ayah, Ibu                                                                 |
| **Count**    | Satu, Dua, Tiga                                                           |
| **Other**    | Teman, Buku                                                               |
| **Fruit**    | Apel, Pisang                                                              |

## Features

- **Real-time camera translation** — Live CameraX preview with on-screen prediction overlay
- **On-device ML** — All inference runs locally via TensorFlow Lite; no network required
- **MediaPipe landmark tracking** — Pose (9 upper-body keypoints) + hands (2 × 21 landmarks)
- **Temporal smoothing** — Majority-vote over a 15-frame history window for stable output
- **Circular frame buffer** — 125-frame native `FloatArray` buffer feeding the TFLite model
- **Camera switch** — Toggle between front and rear cameras
- **Translation history** — Persisted locally via `history.txt` using `path_provider`
- **Skeleton overlay** — Live canvas rendering of detected hand and pose landmarks

## Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    Flutter / Dart (UI)                     │
│  ┌─────────┐  ┌──────────────┐  ┌──────────┐  ┌─────────┐  │
│  │ Home    │  │ Translate    │  │ Artikel  │  │Settings │  │
│  │ Page    │  │ Page         │  │ Page     │  │ Page    │  │
│  └─────────┘  └──────┬───────┘  └──────────┘  └─────────┘  │
│                      │ MethodChannel                       │
├──────────────────────┼─────────────────────────────────────┤
│              Android PlatformView (Kotlin)                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  CameraX (PreviewView)  ◄──►  MediaPipe Landmarker   │  │
│  │                              (Pose + Hand)           │  │
│  │                                       │              │  │
│  │  ┌────────────────────────────────────┘              │  │
│  │  │  assembleFrame() → 51 landmarks × 3 = 153-dim     │  │
│  │  │                                                   │  │
│  │  │  Circular Buffer (125 frames) ──► TFLite Interp.  │  │
│  │  │                        Softmax + Temporal Smooth. │  │
│  │  │                        ──► MethodChannel callback │  │
│  │  └───────────────────────────────────────────────────┘  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

### Data Flow

1. CameraX frames are fed to MediaPipe Hand + Pose Landmarker
2. 51 landmarks (9 pose + 21 left hand + 21 right hand) × 3 (x, y, z) are assembled per frame
3. Landmarks are pushed into a circular 125-frame `FloatArray` buffer
4. When full (or after 30 early-inference frames), the buffer is sent to TFLite `Interpreter.run()` with input shape `[1, 125, 153]`
5. Raw logits (20 classes) go through softmax → confidence threshold (0.8) → majority-vote temporal smoothing (15-frame window)
6. The predicted label is sent back to Dart via `MethodChannel` and rendered in the UI

## Project Structure

```
temanisyarat/
├── lib/
│   ├── main.dart                         # App entry, MainPage, navigation, articles, settings
│   ├── pages/
│   │   └── translate/
│   │       ├── translate_page.dart        # Camera + sign translation UI
│   │       ├── translate_controller.dart  # Business logic, channel bridge, history
│   │       └── widgets/
│   │           └── scanning_dots.dart     # Animated scanning indicator
│   └── services/
│       └── history_service.dart           # Local file persistence for predictions
├── android/app/src/main/kotlin/com/example/android/
│   ├── handlandmarker/
│   │   ├── HandLandmarkerPlugin.kt        # Flutter plugin registration (PlatformViewFactory)
│   │   ├── HandLandmarkerView.kt          # PlatformView: CameraX + landmark buffer + TFLite
│   │   ├── HandLandmarkerHelper.kt        # MediaPipe Hand/Pose Landmarker wrapper
│   │   └── HandLandmarkerOverlay.kt       # Canvas skeleton overlay
│   └── MainActivity.kt                   # FlutterActivity entry
├── android/app/src/main/assets/
│   ├── hand_landmarker.task               # MediaPipe hand landmarker model
│   ├── pose_landmarker_lite.task          # MediaPipe pose landmarker model
│   └── models/
│       └── model_raw.tflite               # Trained TFLite classification model
├── android/                              # Android native project root
├── assets/icon/logo.png                  # App launcher icon
├── pubspec.yaml                          # Flutter dependencies & config
└── .tool-versions                        # Tool version pinning
```

## Tech Stack

### UI Layer (Dart / Flutter)

| Component          | Technology                              |
| ------------------ | --------------------------------------- |
| Framework          | Flutter 3.41 / Dart                     |
| State Management   | `StatefulWidget` + `setState`           |
| Navigation         | `Navigator.push` / Bottom Navigation    |
| Persistence        | `path_provider` (file I/O)              |
| Permissions        | `permission_handler` (camera)           |

### Native Layer (Kotlin / Android)

| Component              | Technology                                           |
| ---------------------- | ---------------------------------------------------- |
| Camera                 | CameraX (view, lifecycle, camera2) 1.4.2             |
| Landmark Detection     | MediaPipe Tasks Vision 0.10.29 (Pose + Hand)         |
| ML Runtime             | TensorFlow Lite 2.14.0 + select TF ops (XNNPACK)    |
| Platform Bridge        | Flutter `MethodChannel` + `PlatformView`              |
| Min SDK                | 24                                                   |
| Kotlin (Gradle plugin) | 2.2.20                                               |
| Gradle                 | 9.5.1                                                |

### ML Model

| Property             | Value                       |
| -------------------- | --------------------------- |
| Input shape          | `[1, 125, 153]`             |
| Output shape         | `[1, 20]` (logits)          |
| Classes              | 20 BISINDO words            |
| Architecture         | GRU + 1D Conv + TempAttention |
| Model size           | ~2.6 MB (TFLite FP16)       |
| Early inference      | Starts at 30 frames (EARLY_INFERENCE_FRAMES) |
| Inference interval   | Every 2nd frame callback (INFERENCE_INTERVAL)  |
| Temporal smoothing   | 15-frame majority vote      |
| Confidence threshold | 0.8                         |

## Getting Started

### Prerequisites

- Flutter 3.41+ (see `.tool-versions`)
- JDK 17+ (OpenJDK 26 recommended)
- Android SDK (compileSdk from Flutter Gradle plugin)
- Android device or emulator (API 24+)

### Setup

```bash
# Clone the repository
git clone https://github.com/temanisyarat/android.git
cd android

# Install Flutter dependencies
flutter pub get

# Run on connected device
flutter run
```

The TFLite model is bundled in `android/app/src/main/assets/models/model_raw.tflite` and is copied to the device cache directory on first launch.

### Lint & Test

```bash
flutter analyze        # Static analysis
flutter test           # Run widget tests
```

## Building

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

> **Note:** Release signing currently uses the debug configuration. Configure a proper release keystore before publishing.
> The TFLite Interpreter uses XNNPACK (`setUseXNNPACK(true)`) for accelerated CPU inference.

## Project Ecosystem

This app is part of the **Teman Isyarat** monorepo, which includes:

| Repository | Purpose |
|---|---|
| [`lm/`](https://github.com/temanisyarat/lm) | MediaPipe landmark extraction pipeline — converts raw BISINDO videos to `.npz` landmark arrays |
| [`model/`](https://github.com/temanisyarat/model) | GRU-based neural network training, evaluation, and TFLite export |
| **`android/`** (you are here) | Flutter + Kotlin Android app for on-device real-time recognition |
| [`manager/`](https://github.com/temanisyarat/manager) | Obsidian vault with ADRs, specs, sprint tracking, and team documentation |

### Data Flow Across Repositories

```
Video (raw MP4)  ──►  lm/  ──►  .npz landmarks  ──►  model/  ──►  .tflite  ──►  android/  ──►  Live predictions
                         (MediaPipe extract)           (Train GRU)              (On-device inference)
```

## License

This project is developed for academic purposes under the Hibah Jarprak program at Universitas Sebelas Maret (UNS), in partnership with GERKATIN Solo.

---

Built with [Flutter](https://flutter.dev), [MediaPipe](https://mediapipe.dev), and [TensorFlow Lite](https://www.tensorflow.org/lite) for Indonesian Sign Language (BISINDO) recognition.
