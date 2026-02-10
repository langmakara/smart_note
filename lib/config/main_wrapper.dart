import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/home/ui/home.dart';
import '../features/calender/ui/calender.dart';
import '../features/notification/ui/notifications_page.dart';
import '../features/settings/ui/settings_page.dart';
import '../providers/theme_provider.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const CalendarPage(),
      const NotificationsPage(),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: themeProvider.bottomNavBgColor,
          boxShadow: [
            BoxShadow(
              color: themeProvider.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Home',
              index: 0,
              themeProvider: themeProvider,
            ),
            _buildNavItem(
              icon: Icons.calendar_month,
              label: 'Calendar',
              index: 1,
              themeProvider: themeProvider,
            ),
            _buildNavItem(
              icon: Icons.notifications,
              label: 'Alerts',
              index: 2,
              themeProvider: themeProvider,
            ),
            _buildNavItem(
              icon: Icons.settings,
              label: 'Settings',
              index: 3,
              themeProvider: themeProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required ThemeProvider themeProvider,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? themeProvider.accentColor
        : themeProvider.subtitleColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _currentIndex = index);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: isSelected
              ? BoxDecoration(
                  color: themeProvider.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? themeProvider.accentColor
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 12 : 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
