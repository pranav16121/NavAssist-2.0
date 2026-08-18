# Technical Overview

This project is a prototype Android assistive navigation app implemented in Flutter, with native Android support for camera, sensing, perception, and voice functionality.

## Flutter Architecture

The app starts from `lib/main.dart`, which creates a `MaterialApp` with a dark high-contrast theme and a set of named routes:

- `/` -> `HomeScreen`
- `/navigation` -> `NavigationScreen`
- `/map_builder` -> `MapBuilderScreen`
- `/saved_maps` -> `SavedMapsScreen`
- `/settings` -> `SettingsScreen`
- `/perception_test` -> `PerceptionTestScreen`

The design is intentionally small and route-driven, which matches the project’s prototype nature.

## Dart Services

The Dart layer is organized around objective-specific services.

### Camera

- `CameraService` defines the common interface.
- `AndroidCameraService` uses `MethodChannel('com.navassist/camera')` to start/stop the native camera and returns a `textureId` for a Flutter `Texture` widget.

### Detection

- `AndroidDetectionService` listens to the `com.navassist/detection` event channel.
- It filters events into two streams:
  - `detections` -> emits `DetectedObstacle` objects
  - `wallStates` -> emits values from the `WallState` enum
- `DetectedObstacle` stores label, confidence, and proximity-like coverage estimate.
- `WallState` values are `none`, `left`, `center`, `right`, and `uniform`.

### Mapping

- `MapStorageService` declares the local map storage interface.
- `LocalMapStorageService` stores map data as JSON files under the application documents directory using `path_provider`.
- Maps are loaded by name and listed via filename scanning.

### Navigation

- `NavigationService` defines the navigation interface.
- `LocalNavigationService` manages route progress, instruction stream, and voice guidance.
- It uses `MovementTracker` and `AndroidVoiceService`.
- It emits instruction strings and progress values from 0.0 to 1.0.

### Sensors

- `AndroidSensorService` bridges Android sensor APIs through method and event channels.
- `StepDetectorService` and `HeadingService` define its contract.
- `MovementTracker` aggregates step counts and heading to estimate segment progress and turning direction.

### Voice

- `VoiceService` defines text-to-speech and speech input operations.
- `AndroidVoiceService` uses `MethodChannel('com.navassist/voice')` and `EventChannel('com.navassist/voice/events')` to call native voice APIs.

## Kotlin Native Integration

The Android side is defined in `android/app/src/main/kotlin/com/navassist/navassist_2`.

### MainActivity

`MainActivity` is the central native bridge. It registers method and event channels for:

- voice operations
- sensor operations
- detection events
- camera lifecycle
- permission handling

It also performs permission requests for:

- `CAMERA`
- `RECORD_AUDIO`
- `ACTIVITY_RECOGNITION`

### MethodChannel

The Android bridge uses `MethodChannel` for commands such as:

- start/stop camera
- start/stop sensors
- speak/stopSpeaking/listen/stopListening
- permission checks and requests

### EventChannel

The native code emits asynchronous data with `EventChannel`, including:

- step events
- heading changes
- speech recognition results
- detection results from ML Kit
- wall-state events

## Camera Pipeline

The actual camera pipeline is implemented in `PerceptionManager.kt`.

- A `ProcessCameraProvider` binds a `Preview` to a Flutter texture.
- A `ImageAnalysis` use case runs at a fixed resolution and uses a `STRATEGY_KEEP_ONLY_LATEST` backpressure mode.
- Each frame is sent to ML Kit object detection.
- The same frame is further processed for wall detection by sampling brightness variations in left/center/right screen regions.
- The preview is exposed to Flutter via `TextureRegistry.SurfaceTextureEntry`.

This gives the app a live preview and a frame-based perception pipeline.

## ML Kit Object Detection

The object detection pipeline uses:

- `ObjectDetection.getClient(...)`
- `ObjectDetectorOptions.Builder()`
- `STREAM_MODE`
- `enableMultipleObjects()`
- `enableClassification()`

In `processImage`, each detection is converted to a map with:

- `label`
- `confidence`
- `coverage`
- bounding box details
- image width and height

The detection events are relayed to Flutter and displayed in `PerceptionTestScreen`.

## Wall Detection

Wall detection is implemented as a lightweight heuristic:

- It samples luminance values across a horizontal region in the image.
- It computes brightness range for left, center, and right zones.
- If the center region has a narrow brightness range and one or more neighboring zones also appear similar, the app maps this to a wall classification.

Possible states emitted to Flutter are:

- `none`
- `left`
- `center`
- `right`
- `uniform`

This is a practical heuristic rather than a full depth-based wall reconstruction method.

## Sensor Services

The Android sensor layer is implemented in `SensorManager.kt`.

- `TYPE_STEP_DETECTOR` is used to detect walking events.
- `TYPE_ROTATION_VECTOR` is used to compute the azimuth and convert it to a heading value in degrees.
- These events are forwarded to Flutter with the `com.navassist/sensors` channels.

The Dart side uses a `MovementTracker` to aggregate these into movement metrics.

## Voice Services

The native voice layer is implemented in `VoiceManager.kt`.

- Android `TextToSpeech` is initialized with US locale.
- `SpeechRecognizer` is created and configured for speech recognition.
- The app can speak navigation instructions and optionally receive recognition results.

In practice, the current user flow is primarily voice output for route guidance, with speech recognition support in the native layer.

## Map Models

The map model is intentionally straightforward:

- `MapNode` stores point metadata:
  - id
  - name
  - x/y position placeholders
  - sequence
  - steps since previous node
  - distance since previous node
  - turn direction
- `MapEdge` stores a connection between nodes with direction metadata.
- `IndoorMap` wraps a node list and edge list and serializes to JSON.

The saved map file format is local JSON in the documents directory, allowing maps to persist between sessions.

## Local Storage

`LocalMapStorageService` writes map JSON to:

- application documents directory
- folder named `maps`
- files named `<map-name>.json`

This is a simple but effective local persistence mechanism for a prototype app.

## Navigation Service

`LocalNavigationService` constructs the prototype navigation engine:

- loads a map
- starts with a destination node
- walks through route segments in sequence
- checks step count progress against each target segment
- speaks route instructions when the next segment begins or when a segment is completed
- stops and announces arrival when the final node is reached

This is a route-logic prototype and does not implement reliable global localization or obstacle-aware path replanning.

## Technical Conclusions

The app is best understood as a prototype assistive system that integrates:

- Flutter UI
- local data persistence
- native Android perception
- sensor-based movement estimation
- speech feedback

It does not currently implement full SLAM, robust localization, or production-grade obstacle avoidance. The code is a solid educational and portfolio prototype rather than a production navigation product.
