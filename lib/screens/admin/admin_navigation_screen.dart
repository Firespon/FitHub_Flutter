import 'package:fithub_user/screens/admin/admin_insights_screen.dart';
import 'package:flutter/material.dart';

// ✅ Correct screen file imports
import 'admin_dashboard_screen.dart';
import 'admin_pending_uploads_screen.dart';
import 'admin_profile_screen.dart';

class AdminNavigationScreen extends StatefulWidget {
  const AdminNavigationScreen({super.key});

  @override
  State<AdminNavigationScreen> createState() => _AdminNavigationScreenState();
}

class _AdminNavigationScreenState extends State<AdminNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminPendingUploadsScreen(),
    AdminInsightsScreen(),
    AdminProfileScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Pending Uploads',
    'Insights',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.pending_actions), label: 'Pending'),
    BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: const Color(0xFF373F51),
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _bottomNavItems,
        selectedItemColor: const Color(0xFF373F51),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFFD8DBE2),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
