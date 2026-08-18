# Future Scope

This project is a promising prototype, but the repository makes clear that several components are still experimental or not yet production-ready. The following areas represent realistic next steps for future development.

## Reliable Indoor Localization

The largest gap is localization. The current app estimates movement using step counts and heading, which is not robust enough for reliable indoor navigation in real-world conditions. Future work should focus on:

- visual-inertial odometry
- better orientation stabilization
- smarter drift correction
- local frame alignment with map landmarks

## Depth Sensing and Spatial Awareness

The current obstacle detection is based on 2D image area and wall heuristics. A more capable system would add:

- depth sensing support
- stereo perception
- accurate object distance estimation
- dynamic obstacle tracking over time

## Spatial Mapping

The map-building flow is basic and manual. Future development could move toward:

- graph-based indoor routing
- corridor segmentation
- obstacle occupancy maps
- more structured map creation workflows

## More Robust Navigation Logic

The current route execution is path-following logic driven by recorded segments and step assumptions. Future work should extend this to:

- graph traversal and routing
- waypoint correction during drift
- dynamic re-routing when obstacles appear
- path planning under uncertainty

## Better Obstacle Distance Estimation

The current ML Kit detection output provides labels and coverage, but not a calibrated distance signal. Future work could improve this by:

- tracking object scale over time
- comparing object footprint to known reference distances
- combining camera info with motion estimates

## Dynamic Obstacle Avoidance

The next major step is not just detecting obstacles, but reacting to them in real-time:

- compute safe paths around obstacles
- replan routes when a corridor is blocked
- announce changes in navigation decisions clearly to the user

## More Robust Voice Navigation

Voice support is already implemented, but it could be improved through:

- better contextual announcements
- user voice command integration
- shorter, more redundant instruction patterns for accessibility
- clear handling of repeated or urgent warnings

## Real-World Usability Testing

The project would benefit substantially from:

- evaluation with actual visually impaired users
- testing in corridors, offices, labs, and homes
- objective assessment of route completion accuracy
- usability studies for voice feedback and interface clarity

## Long-Term Goal

A credible future iteration of NavAssist would aim to become a dependable indoor assistive navigator with real-time perception, precise environment modeling, and well-tested accessibility workflows. That is clearly beyond the present prototype, and it should be treated as a future research direction rather than a current capability.
