import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import the generated Firebase options file
import 'package:list/screens/splash_screen.dart';
import 'package:list/screens/home.dart';
import 'package:list/screens/login.dart';  
import 'package:list/screens/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Initial route is the SplashScreen
      routes: {
        '/': (context) => SplashScreen(), // Splash Screen route
        '/login': (context) => LoginScreen(), // Login Screen route
        '/signup': (context) => SignUpScreen(), // Sign-Up Screen route
        '/home': (context) => HomeScreen(), // Home Screen route
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => SplashScreen()); // Default route
      },
    );
  }
}
