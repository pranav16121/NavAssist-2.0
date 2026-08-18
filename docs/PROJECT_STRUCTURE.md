# Project Structure

This repository is organized around a small Flutter application with Android-native perception and sensor bridges. The structure reflects the prototype nature of the project: UI, local map logic, and Android-native services are kept separate and simple.

## Root Files

- `README.md` — portfolio and project overview
- `pubspec.yaml` — Flutter package metadata and dependencies
- `pubspec.lock` — locked dependency versions
- `analysis_options.yaml` — lint and analysis configuration
- `.gitignore` — Git ignore rules
- `navassist_2.iml` — IDE metadata

## Android Module

The Android project contains the native services that support the app.

### `android/app/src/main/AndroidManifest.xml`

Defines required permissions for:

- camera
- microphone
- activity recognition

It also declares the main activity and app metadata.

### `android/app/src/main/kotlin/com/navassist/navassist_2/MainActivity.kt`

This is the main bridge between Flutter and Android. It registers platform method and event channels for voice, sensors, camera, and permissions. It is the core integration point.

### `android/app/src/main/kotlin/com/navassist/navassist_2/perception/PerceptionManager.kt`

Handles:

- CameraX camera lifecycle
- preview texture creation
- ML Kit object detection
- image analysis
- wall brightness heuristic detection

### `android/app/src/main/kotlin/com/navassist/navassist_2/sensors/SensorManager.kt`

Registers Android sensor listeners for:

- step detection
- rotation vector heading

### `android/app/src/main/kotlin/com/navassist/navassist_2/voice/VoiceManager.kt`

Provides Android text-to-speech and speech recognition capabilities.

### `android/app/src/main/kotlin/com/navassist/navassist_2/arcore/`

This directory contains ARCore-related proof-of-concept files that are explicitly marked as abandoned. They are not part of the active app flow.

## Flutter App

### `lib/main.dart`

Creates the main `NavAssistApp`, configures the theme, and registers named routes.

### `lib/core/`

Contains shared app infrastructure.

- `app_theme.dart` — high-contrast dark theme configuration
- `config/app_config.dart` — configuration values for obstacle sensitivity, wall threshold, and assumed step length
- `utils/permission_utils.dart` — permission handling bridge

### `lib/models/`

Contains the application data model.

- `indoor_map.dart` — overall map model
- `map_node.dart` — route points and metadata
- `map_edge.dart` — route connections between nodes

### `lib/screens/`

Contains the UI screens.

- `home/home_screen.dart` — main menu
- `mapping/map_builder_screen.dart` — map creation workflow
- `mapping/saved_maps_screen.dart` — list saved maps
- `navigation/navigation_screen.dart` — navigation execution interface
- `settings/settings_screen.dart` — tuning settings
- `testing/perception_test_screen.dart` — perception debugging screen
- `testing/arcore_mapping_test_screen.dart` — abandoned proof-of-concept screen

### `lib/services/`

Contains the app’s functional service layer.

#### `camera/`

- `camera_service.dart` — abstract camera interface
- `android_camera_service.dart` — camera bridge to native Android

#### `detection/`

- `obstacle_detection_service.dart` — detection contract
- `wall_detection_service.dart` — wall-state contract
- `android_detection_service.dart` — native detection event parser

#### `mapping/`

- `map_storage_service.dart` — map storage contract
- `local_map_storage_service.dart` — JSON persistence backed by local files

#### `navigation/`

- `navigation_service.dart` — navigation interface
- `local_navigation_service.dart` — route progress and voice guidance logic

#### `sensors/`

- `step_detector_service.dart`
- `heading_service.dart`
- `android_sensor_service.dart`
- `movement_tracker.dart`

#### `voice/`

- `voice_service.dart`
- `android_voice_service.dart`

## Test Folder

The `test/` directory contains a basic Flutter widget test scaffold. It does not represent the full validation of the app’s assistive functionality.

## Assets

The `assets/screenshots/` directory is intended as a home for presentation screenshots and demonstration images. The screenshot files themselves are not currently present in the repository.
