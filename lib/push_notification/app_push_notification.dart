import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialisation Android
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  // Initialisation iOS
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Créer le channel Android
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Foreground notifications iOS
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;

  if (notification == null || kIsWeb) return;

  final AndroidNotification? android = message.notification?.android;

  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      // FIX: ajout du support iOS — manquait dans l'ancienne version
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<String> getFcmDeviceToken() async {
  String? token;
  try {
    token = await FirebaseMessaging.instance.getToken();
    log("Device token ::: $token");
  } catch (e, tr) {
    log("Firebase Error -> $e");
    log("Firebase Error track -> $tr");
  }
  return token ?? "";
}

/// S'abonner à un topic Firebase
/// À appeler après la connexion quand le rôle est connu
Future<void> subscribeToTopic(String topic) async {
  try {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    log("Subscribed to topic: $topic");
  } catch (e) {
    log("Subscribe error: $e");
  }
}

/// Se désabonner d'un topic Firebase
/// À appeler à la déconnexion
Future<void> unsubscribeFromTopic(String topic) async {
  try {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    log("Unsubscribed from topic: $topic");
  } catch (e) {
    log("Unsubscribe error: $e");
  }
}