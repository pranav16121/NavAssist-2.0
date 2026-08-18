import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/navigation/navigation_screen.dart';
import 'screens/mapping/map_builder_screen.dart';
import 'screens/mapping/saved_maps_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/testing/perception_test_screen.dart';

void main() {
  runApp(const NavAssistApp());
}

class NavAssistApp extends StatelessWidget {
  const NavAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NavAssist 2.0',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.highContrastTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/navigation': (context) => const NavigationScreen(),
        '/map_builder': (context) => const MapBuilderScreen(),
        '/saved_maps': (context) => const SavedMapsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/perception_test': (context) => const PerceptionTestScreen(),
      },
    );
  }
}
