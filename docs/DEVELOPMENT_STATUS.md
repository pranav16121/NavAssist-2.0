# Development Status

This status table reflects the code that is actually present in the repository as of this inspection.

| Feature | Status | Evidence / Notes |
|---|---|---|
| Flutter app shell and routing | WORKING | `lib/main.dart` defines named routes for home, navigation, map builder, saved maps, settings, and perception test. |
| High-contrast accessibility UI | WORKING | `lib/core/app_theme.dart` defines a dark theme with gold-accent styling and large interactive controls. |
| Local map persistence | WORKING | `LocalMapStorageService` writes and reads JSON map files in the application documents directory. |
| Saved map listing and deletion | WORKING | `SavedMapsScreen` loads saved maps and delete operations are implemented. |
| Map builder interface | WORKING | `MapBuilderScreen` allows adding point names and saving a map with recorded metadata. |
| Movement-aware point marking | PARTIAL | Marked points record estimated distance and turn metadata based on step counts and heading, but no real localization is used. |
| Navigation flow | PARTIAL | `LocalNavigationService` uses recorded map metadata and step counts to drive instruction and progress updates. |
| Voice instructions | WORKING | `AndroidVoiceService` and `VoiceManager.kt` implement Android text-to-speech output. |
| Camera preview | WORKING | `PerceptionManager.kt` binds CameraX preview to a Flutter `Texture`. |
| ML Kit object detection | WORKING | `PerceptionManager.kt` uses Google ML Kit to detect objects and emit events to Flutter. |
| Wall detection heuristic | PARTIAL | Brightness sampling in left/center/right zones creates wall-state estimates, but it is a simplified heuristic. |
| Obstacle proximity estimation | PARTIAL | `coverage` is computed from object bounding box area relative to the image frame; it is not a calibrated depth model. |
| Step detection | PARTIAL | Android `STEP_DETECTOR` is used, but it is a simple event trigger and not a robust gait model. |
| Heading estimation | PARTIAL | Rotation-vector orientation is used to estimate azimuth, which is approximate and affected by real-world drift. |
| Indoor localization | PROTOTYPE | The app stores points and advances using step assumptions, but it does not provide robust real-time indoor localization. |
| Route guidance realism | PROTOTYPE | The app can guide along a manually recorded route, but there is no robust path-planning or correction system. |
| Permission handling | WORKING | `PermissionUtils` and `MainActivity` request camera, microphone, and activity recognition permissions. |
| ARCore proof-of-concept | EXPERIMENTAL | Files under `android/app/src/main/kotlin/com/navassist/navassist_2/arcore/` are explicitly marked as abandoned and are not wired into the active app. |
| Production-ready navigation | FUTURE | The current implementation should not be considered a reliable assistive or safety navigation system. |
| Dynamic obstacle avoidance | FUTURE | No real-time dynamic path replanning or obstacle avoidance logic is implemented. |
| Real-world usability validation | FUTURE | The project is not yet validated with real assistive use cases in operation. |
