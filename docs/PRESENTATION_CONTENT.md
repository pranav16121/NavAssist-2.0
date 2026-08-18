# Presentation Content

This document is organized for a concise, honest, portfolio-ready 12-slide talk.

## Slide 1 — NavAssist 2.0

- PROJECT: NavAssist 2.0
- TYPE: Android + Flutter assistive technology prototype
- FOCUS: environmental awareness and indoor guidance for visually impaired users
- STATUS: WORKING prototype foundation with clear limitations

Recommended visual:
- Home screen screenshot or polished app splash/mockup

Speaker notes:
- This project explores how mobile hardware can support indoor awareness and route guidance for visually impaired users.
- The goal is not to claim fully autonomous navigation; it is to demonstrate a useful prototype foundation.

## Slide 2 — Problem Statement

- Unfamiliar indoor spaces are hard to navigate without visual awareness
- Walls, obstacles, and turns are difficult to interpret in real time
- Independent movement often depends on uncertain or incomplete feedback
- Assistive tools need to be simple, accessible, and understandable

Recommended visual:
- Simple hallway illustration with obstacles, turns, and a user device

Speaker notes:
- The project starts from a real user problem: environmental uncertainty in indoor spaces.
- The app is designed around accessibility, not around pretending to replace full perception systems.

## Slide 3 — Motivation

- Improve confidence and independence in unfamiliar indoor spaces
- Use ordinary Android hardware as a practical platform
- Combine perception, voice, and accessibility into one design
- Build a low-cost prototype to explore the problem space

Recommended visual:
- Diagram of user + mobile app + environment + spoken guidance loop

Speaker notes:
- The motivation is realistic and practical.
- This project is a proof-of-concept to study how assistive feedback can be structured.

## Slide 4 — Proposed Solution

- Use live camera input, sensors, and voice output together
- Detect nearby objects and wall-like conditions
- Build simple indoor route metadata from user movement
- Deliver instructions in an accessible, voice-first way

Recommended visual:
- Flow diagram: camera + sensors → perception → map → voice guidance

Speaker notes:
- The solution is intentionally modest and prototype-oriented.
- It demonstrates a useful design pattern, not a production safety system.

## Slide 5 — How NavAssist Works

- User opens the app and chooses a screen
- Camera and sensors start when needed
- ML Kit emits object events and wall-state estimates
- User records route points in the Map Builder
- Navigation follows recorded segment metadata and speaks instructions

Recommended visual:
- Step-by-step UI flow from home → perception → map builder → navigation

Speaker notes:
- This is the clearest demonstration of the app’s actual behavior.
- The system is route-based and sensor-assisted rather than fully autonomous.

## Slide 6 — System Architecture

- Flutter UI drives the main user experience
- Native Android bridge handles voice, sensors, and camera
- CameraX and ML Kit run the perception pipeline
- Local JSON files store indoor map data
- The design stays lightweight and modular

Recommended visual:
- Layered architecture diagram with UI, services, native Android, and sensors

Speaker notes:
- This architecture is intentionally simple and readable.
- It maps directly to the repository and reflects the current implementation.

## Slide 7 — AI / Computer Vision

- ML Kit object detection is active in the perception pipeline
- Bounding boxes and confidence values are emitted to Flutter
- Wall detection uses brightness sampling in screen regions
- This is a prototype perception layer, not a full depth system

Recommended visual:
- Screen capture of detection labels over a live frame

Speaker notes:
- The system demonstrates perception, but it is honest about the limits.
- It is useful for assistive awareness, not for precise spatial reconstruction.

## Slide 8 — Voice-First Accessibility

- Spoken prompts are used for navigation information
- Large high-contrast interface supports easier interaction
- Layout is simplified for quick scanning and reduced clutter
- Accessibility is treated as a first-class design goal

Recommended visual:
- UI mockup showing large button text and speech output pattern

Speaker notes:
- Voice feedback is a major design feature of the app.
- This is especially relevant for users who cannot rely heavily on visual-only interfaces.

## Slide 9 — Indoor Mapping & Navigation

- Map Builder records route points with movement metadata
- Distance and heading are estimated from step counts and rotation data
- Navigation follows a recorded path and announces instructions
- This is a prototype route engine, not robust localization

Recommended visual:
- Map Builder screen plus navigation progress display

Speaker notes:
- This is a useful concept demo, but the limitations are real.
- The app does not currently provide reliable autonomous indoor localization.

## Slide 10 — Technology Stack

- Flutter and Dart for UI and app logic
- Android and Kotlin for native integration
- CameraX for preview and analysis
- Google ML Kit for object detection
- Android sensors for steps and heading
- local JSON storage and SharedPreferences for persistence

Recommended visual:
- Tool-grid or stack diagram

Speaker notes:
- The technology stack is intentionally lightweight and accessible.
- This keeps the project practical while still demonstrating real native integration.

## Slide 11 — Current Results + Limitations

- WORKING: camera preview, object detection, settings, VOICE output, saved maps
- PROTOTYPE: route following, map creation, and movement estimation
- LIMITATION: localization is approximate and not production-safe
- Future improvement is needed before real-world assistive deployment

Recommended visual:
- Simple status matrix: WORKING / PROTOTYPE / LIMITATION / FUTURE

Speaker notes:
- This is the honest part of the project story.
- The app is valuable as a research prototype, but it should not be presented as a dependable safety system.

## Slide 12 — Future Scope

- Reliable visual-inertial odometry and drift correction
- Better indoor localization and route alignment
- Depth sensing and stronger obstacle-distance estimation
- Dynamic obstacle avoidance and graph-based routing
- Real-world accessibility testing in actual indoor environments

Recommended visual:
- Roadmap or milestone timeline

Speaker notes:
- This is where the project can evolve from a prototype into a more serious assistive system.
- The current app is a strong foundation, but the next steps are substantial.
