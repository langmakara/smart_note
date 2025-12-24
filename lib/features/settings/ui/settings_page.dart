import 'package:flutter/material.dart';
import '../widget/theme_switch_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false; // បច្ចុប្បន្នទុកវាជា state ក្នុង page សិន

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Appearance",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ThemeSwitchTile(
            isDarkMode: _isDarkMode,
            onThemeChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              // កន្លែងនេះអ្នកនឹងត្រូវហៅ Logic ដើម្បីប្តូរ Theme App ទាំងមូល
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.purple),
            title: const Text("Language"),
            trailing: const Text("English"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.purple),
            title: const Text("About Smart Note"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}