import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    debugPrint("Background Message Received: ${message.messageId}");
  }

  Future<void> registerPushNotificationHandler() async {
    // Request permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or did not accept permission');
    }

    // Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Local Notification Setup
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    var initializationSettingsAndroid =
    const AndroidInitializationSettings('@drawable/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onSelectNotification(response.payload);
      },
    );

    // Foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("Foreground Message: ${message.notification?.title}");

      RemoteNotification? notification = message.notification;

      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              color: Colors.blue,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // Handle notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification Clicked: ${message.data}");
    });

    debugPrint("Notification Service Registered");
  }

  void onSelectNotification(String? data) {
    debugPrint("Local Notification Clicked: $data");
    if (data?.isNotEmpty ?? false) {
      try {
        Map<String, dynamic> payload = jsonDecode(data!);
        debugPrint("Notification Payload: $payload");

      } catch (e) {
        debugPrint("Error decoding notification payload: $e");
      }
    }
  }

  Future<String> getDeviceToken() async {
    String token = await messaging.getToken() ?? "";
    debugPrint('Firebase Token: $token');
    return token;
  }
}
