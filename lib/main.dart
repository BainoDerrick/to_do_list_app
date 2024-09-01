import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import Flutter Local Notifications
import 'package:timezone/data/latest.dart' as tz; // Import Timezone Data
import 'package:timezone/timezone.dart' as tz; // Import Timezone Library
import 'firebase_options.dart'; // Import the generated Firebase options file
import 'package:list/screens/splash_screen.dart';
import 'package:list/screens/home.dart';
import 'package:list/screens/login.dart';
import 'package:list/screens/signup.dart';
import 'package:list/screens/settings.dart'; // Import Settings Screen
import 'package:provider/provider.dart'; // Import Provider

// Create an instance of the FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  // Initialize time zone data
  tz.initializeTimeZones();

  // Define notification settings for Android
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: IOSInitializationSettings(),
  );

  // Initialize the Flutter Local Notifications Plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel_id', // Channel ID
    'Default Channel', // Channel name
    description: 'This is the default channel for notifications.',
    importance: Importance.max, // High importance
  );

  // Create the channel on Android
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications
  await initializeNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My To-Do App',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/', // Initial route is the SplashScreen
      routes: {
        '/': (context) => SplashScreen(), // Splash Screen route
        '/login': (context) => LoginScreen(), // Login Screen route
        '/signup': (context) => SignUpScreen(), // Sign-Up Screen route
        '/home': (context) => HomeScreen(), // Home Screen route
        '/settings': (context) => SettingsScreen(), // Settings Screen route
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => SplashScreen()); // Default route
      },
    );
  }
}

// Theme Mode Provider
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    notifyListeners();
  }
}
