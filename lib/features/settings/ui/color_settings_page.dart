import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_settings_model.dart';
import '../../../providers/theme_provider.dart';

class ColorSettingsPage extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;

  const ColorSettingsPage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<ColorSettingsPage> createState() => _ColorSettingsPageState();
}

class _ColorSettingsPageState extends State<ColorSettingsPage> {
  late AppSettings _settings;

  final List<Color> _colorOptions = [
    Colors.purple,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _updateSettings(AppSettings newSettings) {
    setState(() => _settings = newSettings);
    widget.onSettingsChanged(newSettings);
    // Update the ThemeProvider with the new accent color
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.setAccentColor(newSettings.accentColor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Accent Color',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
      body: Column(
        children: [
          // Preview
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _settings.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _settings.accentColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.color_lens,
                  size: 48,
                  color: _settings.accentColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Current Accent Color',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getColorName(_settings.accentColor),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _settings.accentColor,
                  ),
                ),
              ],
            ),
          ),
          // Color Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _colorOptions.length,
              itemBuilder: (context, index) {
                final color = _colorOptions[index];
                final isSelected = _settings.accentColor.value == color.value;
                return GestureDetector(
                  onTap: () {
                    _updateSettings(_settings.copyWith(accentColor: color));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Accent color changed to ${_getColorName(color)}'),
                        backgroundColor: color,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Colors.white,
                              width: 4,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getColorName(Color color) {
    final colorMap = {
      Colors.purple.value: 'Purple',
      Colors.blue.value: 'Blue',
      Colors.green.value: 'Green',
      Colors.orange.value: 'Orange',
      Colors.red.value: 'Red',
      Colors.teal.value: 'Teal',
      Colors.pink.value: 'Pink',
      Colors.indigo.value: 'Indigo',
      Colors.amber.value: 'Amber',
      Colors.cyan.value: 'Cyan',
      Colors.lime.value: 'Lime',
      Colors.brown.value: 'Brown',
    };
    return colorMap[color.value] ?? 'Custom';
  }
}
