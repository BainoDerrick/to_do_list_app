import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: IOSInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // Initialize timezones
    tz.initializeTimeZones();
  }

  static Future<void> scheduleNotification(DateTime scheduledDateTime, String title, String body, {required String channelId}) async {
    // Convert DateTime to TZDateTime
    final tz.TZDateTime scheduledDateTimeTZ = tz.TZDateTime.from(scheduledDateTime, tz.local);

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'default_channel_id', // You can change this
        'Default Channel', // You can change this
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: IOSNotificationDetails(),
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      title,
      body,
      scheduledDateTimeTZ,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
