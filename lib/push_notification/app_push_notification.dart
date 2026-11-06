import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../app/database/auth_database.dart';
import '../app/routes/app_pages.dart';

/// Topics auxquels la connexion abonne l'appareil
const List<String> notificationTopics = [
  'all_users',
  'admins',
  'students',
  'parents',
  'teachers',
];

bool _openNotificationsWhenReady = false;

/// Ouvre la liste des notifications après un clic sur l'une d'elles.
void openNotifications() {
  if (AuthDatabase.instance.auth()) {
    Get.toNamed(Routes.NOTIFICATION);
  }
}

/// Application lancée depuis une notification : l'accueil ouvrira la liste une fois affiché.
void openNotificationsWhenReady() {
  _openNotificationsWhenReady = true;
}

void openPendingNotifications() {
  if (_openNotificationsWhenReady) {
    _openNotificationsWhenReady = false;
    openNotifications();
  }
}

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
  AndroidInitializationSettings('@mipmap/launcher_icon');

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

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (_) => openNotifications(),
  );

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
        icon: '@mipmap/launcher_icon',
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
Future<void> unsubscribeFromTopic(String topic) async {
  try {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    log("Unsubscribed from topic: $topic");
  } catch (e) {
    log("Unsubscribe error: $e");
  }
}

/// Se désabonner de tous les topics, à la déconnexion
Future<void> unsubscribeFromAllTopics() async {
  await Future.wait(notificationTopics.map(unsubscribeFromTopic));
}