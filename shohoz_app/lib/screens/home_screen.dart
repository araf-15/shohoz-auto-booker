import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'search_screen.dart';
import 'profiles_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    SearchScreen(),
    ProfilesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF4ADE80),
          unselectedItemColor: Colors.white38,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text('${provider.profiles.length}'),
                isLabelVisible: provider.profiles.isNotEmpty,
                child: const Icon(Icons.person),
              ),
              label: 'Profiles',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.power_settings_new,
                color: provider.isGlobalActive ? const Color(0xFF4ADE80) : Colors.white38,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
