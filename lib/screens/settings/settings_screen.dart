import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SharedPreferences _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        AppConfig.obstacleCoverageThreshold = _prefs.getDouble('obstacleThreshold') ?? 0.50;
        AppConfig.wallBrightnessThreshold = _prefs.getInt('wallThreshold') ?? 40;
        AppConfig.assumedStepLength = _prefs.getDouble('stepLength') ?? 0.75;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateObstacleThreshold(double value) async {
    await _prefs.setDouble('obstacleThreshold', value);
    setState(() => AppConfig.obstacleCoverageThreshold = value);
  }

  Future<void> _updateWallThreshold(int value) async {
    await _prefs.setInt('wallThreshold', value);
    setState(() => AppConfig.wallBrightnessThreshold = value);
  }

  Future<void> _updateStepLength(double value) async {
    await _prefs.setDouble('stepLength', value);
    setState(() => AppConfig.assumedStepLength = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.yellow))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader('NAVIGATION PARAMETERS'),
                _buildSliderSetting(
                  label: 'STEP LENGTH (METERS)',
                  value: AppConfig.assumedStepLength,
                  onChanged: (val) => _updateStepLength(val),
                  min: 0.3,
                  max: 1.2,
                  subtitle: 'Default is 0.75m. Adjust based on your stride.',
                ),
                const SizedBox(height: 16),
                _buildHeader('PERCEPTION PARAMETERS'),
                _buildSliderSetting(
                  label: 'OBSTACLE SENSITIVITY',
                  value: AppConfig.obstacleCoverageThreshold,
                  onChanged: (val) => _updateObstacleThreshold(val),
                  min: 0.1,
                  max: 0.9,
                  subtitle: 'Higher = Must be closer to alert',
                ),
                _buildSliderSetting(
                  label: 'WALL BRIGHTNESS RANGE',
                  value: AppConfig.wallBrightnessThreshold.toDouble(),
                  onChanged: (val) => _updateWallThreshold(val.toInt()),
                  min: 10,
                  max: 100,
                  subtitle: 'Lower = More strict wall detection',
                ),
                const SizedBox(height: 32),
                _buildHeader('APP INFORMATION'),
                const ListTile(
                  title: Text('VERSION', style: TextStyle(color: Colors.yellow)),
                  subtitle: Text('2.0.0 (BETA)', style: TextStyle(color: Colors.white70)),
                ),
                const ListTile(
                  title: Text('LICENSE', style: TextStyle(color: Colors.yellow)),
                  subtitle: Text('Offline-first Production Prototype', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    await _prefs.clear();
                    await _loadSettings();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings reset to default')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text('RESET ALL SETTINGS'),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.yellow),
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
        Slider(
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
          activeColor: Colors.yellow,
          inactiveColor: Colors.grey[800],
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
        const Divider(color: Colors.grey),
      ],
    );
  }
}
