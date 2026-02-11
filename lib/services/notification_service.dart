import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/event_model.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    await _createNotificationChannel();
    await requestPermissions();
  }

  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'event_reminders',
      'Event Reminders',
      description: 'Notifications for event reminders',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleEventReminder(Event event) async {
    if (event.reminderMinutes == null || event.reminderMinutes == 0) {
      return;
    }

    final reminderTime = event.startTime.subtract(
      Duration(minutes: event.reminderMinutes!),
    );

    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    String reminderText;
    final minutes = event.reminderMinutes!;
    if (minutes < 60) {
      reminderText = 'in $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      reminderText = 'in $hours hour${hours > 1 ? 's' : ''}';
    } else if (minutes < 10080) {
      final days = minutes ~/ 1440;
      reminderText = 'in $days day${days > 1 ? 's' : ''}';
    } else {
      final weeks = minutes ~/ 10080;
      reminderText = 'in $weeks week${weeks > 1 ? 's' : ''}';
    }

    final androidDetails = AndroidNotificationDetails(
      'event_reminders',
      'Event Reminders',
      channelDescription: 'Your upcoming event reminders',
      importance: Importance.high,
      icon: '@mipmap/ic_launcher',
      color: event.color,
      colorized: true,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(
        '"${event.title}" starts $reminderText\n\n${event.description.isNotEmpty ? event.description : 'Tap to view details'}',
        contentTitle: 'Event Reminder',
        summaryText: event.description.isNotEmpty
            ? event.description
            : 'Tap to view details',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
      reminderTime,
      tz.local,
    );

    await _notifications.zonedSchedule(
      event.id.hashCode,
      'Event Reminder',
      '"${event.title}" starts $reminderText',
      scheduledTime,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: event.id,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelEventReminder(String eventId) async {
    await _notifications.cancel(eventId.hashCode);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingReminders() async {
    return await _notifications.pendingNotificationRequests();
  }
}
