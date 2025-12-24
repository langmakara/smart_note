import 'package:flutter/material.dart';
import '../features/home/ui/home.dart';     // import home page របស់អ្នក
import '../features/calender/ui/calender.dart'; // import calendar page របស់អ្នក
import '../features/notification/ui/notifications_page.dart'; // import notification page របស់អ្នក
import '../features/settings/ui/settings_page.dart'; // import settings page របស់អ្នក

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0; // កំណត់ index បច្ចុប្បន្ន

  // បញ្ជីទំព័រដែលចង់បង្ហាញ
  final List<Widget> _pages = [
    const HomePage(),
    const CalendarPage(),
    const NotificationsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack ជួយរក្សាស្ថានភាពទំព័រ (មិនឱ្យបាត់ទិន្នន័យពេលដូរទៅមក)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        color: Colors.purple,
        padding: const EdgeInsets.only(bottom: 10, top: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 0),
            _buildNavItem(Icons.calendar_month, 1),
            _buildNavItem(Icons.notifications, 2),
            _buildNavItem(Icons.settings, 3),
          ],
        ),
      ),
    );
  }

  // Widget សម្រាប់បង្កើតប៊ូតុងនីមួយៗ
  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(icon, size: 30),
      color: _currentIndex == index ? Colors.yellow : Colors.white,
      onPressed: () {
        setState(() {
          _currentIndex = index; // នៅពេលចុច វានឹងដូរ index ដើម្បីដូរ Page
        });
      },
    );
  }
}