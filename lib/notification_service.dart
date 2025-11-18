import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 🔹 Initialize notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@drawable/ic_notification.png'); // your white Q icon

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInitSettings);

    await _notificationsPlugin.initialize(initSettings);
    tz.initializeTimeZones();
  }

  // 🔹 Save current open time
  static Future<void> recordAppOpened() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_open_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  // 🔹 Check inactivity and schedule if needed
  static Future<void> checkAndScheduleIfInactive() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastMs = prefs.getInt('last_open_timestamp');

    if (lastMs != null) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
      final diffDays = now.difference(last).inDays;

      if (diffDays >= 3) {
        // user hasn’t opened for 3+ days → schedule motivational notification
        await scheduleNotification(
          title: 'Hey saver! 💰',
          body: 'It’s been a while 👀  Open the app and check your progress today!',
          delay: const Duration(seconds: 5), // shows within 5 s
        );
      }
    }
  }

  // 🔹 Instant notification
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'General Notifications',
      channelDescription: 'App notifications for user engagement',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      icon: '@drawable/ic_notification.png',
    );

    const details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, title, body, details);
  }

  // 🔹 Schedule notification after delay
  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      1,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(delay),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'scheduled_channel',
          'Scheduled Notifications',
          channelDescription: 'Reminders and motivational notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/ic_notification.png',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime;
    );
  }

  // ✅ Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // ✅ Reschedule all notifications (after app restarts or new data)
  static Future<void> rescheduleAllNotifications() async {
    await _notificationsPlugin.cancelAll();

    // Schedule after 3 days
    await scheduleNotification(
      title: "💪 Keep your savings goal alive!",
      body: "It’s been a few days since your last visit — open the app and complete your next level 🎯",
      delay: const Duration(days: 3),
    );

    // Schedule after 5 days
    await scheduleNotification(
      title: "💰 Don’t forget your progress!",
      body: "Small steps make big savings 🌱 Jump back in today!",
      delay: const Duration(days: 5),
    );
  }
}








