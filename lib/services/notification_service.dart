import 'dart:io';
<<<<<<< HEAD
import 'package:flutter/foundation.dart';
=======
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
<<<<<<< HEAD
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      print('Notifications are not supported on this platform');
      return;
    }

=======
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
<<<<<<< HEAD
          defaultPresentAlert: true,
          defaultPresentBadge: true,
          defaultPresentSound: true,
=======
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
    await _createNotificationChannel();
    await _requestPermissions();
  }

  static Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'task_channel',
        'Task Reminders',
        description: 'Channel for task reminder notifications',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
        showBadge: true,
      );

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
      }
    }
  }

  static Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
<<<<<<< HEAD
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
=======
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
<<<<<<< HEAD
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      print('Scheduling notifications is not supported on this platform');
      return;
    }

=======
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'task_channel',
            'Task Reminders',
            channelDescription: 'Channel for task reminder notifications',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            ticker: 'Task Reminder',
            autoCancel: true,
            showWhen: true,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
        threadIdentifier: 'task-reminders',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tz.TZDateTime scheduledTzTime = tz.TZDateTime.from(
        scheduledTime.toLocal(),
        tz.local,
      );

      if (scheduledTzTime.isBefore(tz.TZDateTime.now(tz.local))) {
        print('Notification time is in the past: $scheduledTzTime');
        return;
      }

      print('Scheduling notification for: $scheduledTzTime');

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTzTime,
        platformDetails,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

      print('Notification scheduled successfully with ID: $id');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
<<<<<<< HEAD
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      print('Instant notifications are not supported on this platform');
      return;
    }

=======
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'task_channel',
          'Task Reminders',
          channelDescription: 'Channel for task reminder notifications',
          importance: Importance.max,
          playSound: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(id, title, body, platformDetails);
  }

  static Future<bool> areNotificationsEnabled() async {
<<<<<<< HEAD
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      print('Checking notification status is not supported on this platform');
      return false;
    }

=======
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
    if (Platform.isAndroid) {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.areNotificationsEnabled();
      return result ?? false;
    } else if (Platform.isIOS) {
<<<<<<< HEAD
      final NotificationsEnabledOptions? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return result?.isEnabled ?? false;
=======
      return true;
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
    }
    return false;
  }

  static Future<bool> requestNotificationPermission() async {
<<<<<<< HEAD
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      print(
        'Requesting notification permission is not supported on this platform',
      );
      return false;
    }

=======
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? granted = await androidImplementation
          ?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
<<<<<<< HEAD
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
=======
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      return true;
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
    }
    return false;
  }

  static Future<void> cancelNotification(int id) async {
<<<<<<< HEAD
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      print('Cancelling notifications is not supported on this platform');
      return;
    }

=======
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
    try {
      await _notificationsPlugin.cancel(id);
      print('Notification cancelled with ID: $id');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
<<<<<<< HEAD
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      print('Cancelling all notifications is not supported on this platform');
      return;
    }

=======
>>>>>>> 7cc58fbed4ff8c6d125cde0ad0777e420deea963
    try {
      await _notificationsPlugin.cancelAll();
      print('All notifications cancelled');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }
}
