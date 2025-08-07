import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'upload_screen.dart';
import 'appointments_screen.dart';
// import 'chat_screen.dart';
import 'ratings_screen.dart';
import 'profile_screen.dart';

class TrainerNavigationScreen extends StatefulWidget {
  const TrainerNavigationScreen({super.key});

  @override
  State<TrainerNavigationScreen> createState() =>
      _TrainerNavigationScreenState();
}

class _TrainerNavigationScreenState extends State<TrainerNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    TrainerHomeScreen(),
    UploadContentScreen(),
    AppointmentsScreen(),
    RatingsScreen(),
    TrainerProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Upload'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Ratings'),
          // BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
