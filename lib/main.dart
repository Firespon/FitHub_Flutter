import 'package:fithub_user/screens/trainer/appointments_screen.dart';
import 'package:fithub_user/screens/trainer/ratings_screen.dart';
import 'package:fithub_user/screens/trainer/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/auth/login_screen.dart';
import 'screens/customer/navigation_screen.dart';
import 'screens/customer/edit_profile_screen.dart';
import 'screens/customer/change_password_screen.dart';
import 'screens/customer/bookmark_screen.dart';
import 'screens/trainer/navigation_screen.dart';
import 'screens/trainer/home_screen.dart';
import 'screens/trainer/trainer_chat_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(create: (_) => ThemeController(), child: MyApp()),
  );
}

class ThemeController with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeController>(context);

    return MaterialApp(
      title: 'FitHub',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Color(0xFFD8DBE2),
        primaryColor: Color(0xFF5E05DA),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF5E05DA),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF5E05DA),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF1B1B1E),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1B1B1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF5E05DA),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        iconTheme: IconThemeData(color: Colors.white70),
      ),
      home: FutureBuilder(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return snapshot.data!;
          }
          return LoginScreen(); // fallback
        },
      ),
      routes: {
        '/navigation': (context) => NavigationScreen(),
        '/editProfile': (context) => EditProfileScreen(),
        '/changePassword': (context) => ChangePasswordScreen(),
        '/Bookmarks': (context) => BookmarksScreen(),
        '/trainerHome': (context) => TrainerHomeScreen(),
        '/trainerAppointments': (context) => AppointmentsScreen(),
        '/trainerChats':
            (context) => TrainerChatListScreen(
              trainerId: FirebaseAuth.instance.currentUser!.uid,
            ),
        '/trainerRatings': (context) => RatingsScreen(),
        '/trainerUpload': (context) => UploadContentScreen(),
      },
    );
  }

  Future<Widget> _getInitialScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return LoginScreen();

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    final role = doc.data()?['role'] ?? 'customer'; // default to 'user'

    if (role == 'trainer') {
      return TrainerNavigationScreen(); // you must create this file
    } else {
      return NavigationScreen(); // customer
    }
  }
}
