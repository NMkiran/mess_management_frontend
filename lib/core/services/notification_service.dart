import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AwesomeNotifications _awesomeNotifications = AwesomeNotifications();

  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('UTC'));

      // Initialize Android Alarm Manager
      await AndroidAlarmManager.initialize();

      // Initialize Awesome Notifications
      await _awesomeNotifications.initialize(
        null, // null means use default app icon
        [
          NotificationChannel(
            channelKey: 'alarm_channel',
            channelName: 'Alarm Notifications',
            channelDescription: 'Channel for alarm notifications',
            defaultColor: Colors.red,
            ledColor: Colors.red,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            enableVibration: true,
            enableLights: true,
            playSound: true,
            soundSource: 'resource://raw/patrol',
            criticalAlerts: true,
          ),
        ],
        debug: true,
      );

      // Initialize Flutter Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
          // Handle notification tap
        },
      );

      // Request notification permissions
      await _awesomeNotifications.requestPermissionToSendNotifications();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
      rethrow;
    }
  }

  Future<void> scheduleAlarm(DateTime scheduledTime) async {
    try {
      // Cancel any existing alarms
      await cancelAllAlarms();

      // Schedule with Awesome Notifications
      await _awesomeNotifications.createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'alarm_channel',
          title: 'Alarm',
          body: 'Time to wake up!',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledTime,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
      );

      // Schedule with Android Alarm Manager as backup
      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        1,
        _showAlarmNotification,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      debugPrint('Alarm scheduled for: ${scheduledTime.toString()}');
    } catch (e) {
      debugPrint('Error scheduling alarm: $e');
      rethrow;
    }
  }

  Future<void> cancelAllAlarms() async {
    try {
      await _awesomeNotifications.cancelAll();
      await AndroidAlarmManager.cancel(1);
    } catch (e) {
      debugPrint('Error canceling alarms: $e');
    }
  }

  static Future<void> _showAlarmNotification() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Notifications',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('patrol'),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.event,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      'Alarm',
      'Time to wake up!',
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleMessAlarm({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await scheduleAlarm(scheduledTime);
  }
}
