import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            // Restore Perception Test long-press
            Navigator.pushNamed(context, '/perception_test');
          },
          child: const Text('NAVASSIST 2.0'),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _MenuButton(
                label: 'START NAVIGATION',
                icon: Icons.navigation,
                onPressed: () => Navigator.pushNamed(context, '/navigation'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _MenuButton(
                label: 'MAP BUILDER',
                icon: Icons.add_location_alt,
                onPressed: () => Navigator.pushNamed(context, '/map_builder'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _MenuButton(
                label: 'SAVED MAPS',
                icon: Icons.map,
                onPressed: () => Navigator.pushNamed(context, '/saved_maps'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _MenuButton(
                label: 'SETTINGS',
                icon: Icons.settings,
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 48),
      label: Text(
        label,
        textAlign: TextAlign.center,
      ),
    );
  }
}
