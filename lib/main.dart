import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aramisc/app/data/constants/app_colors.dart';
import 'package:aramisc/config/global_variable/global_variable_controller.dart';
import 'package:aramisc/firebase_options.dart';
import 'package:aramisc/push_notification/app_push_notification.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'config/language/controller/language_controller.dart';
import 'initializer.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  debugPrint('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Initializer.init();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);

  // Handler pour les messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialisation complète des notifications
  await setupFlutterNotifications();

  // Demander la permission (obligatoire sur iOS, recommandé Android 13+)
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
  log('Permission notifications: ${settings.authorizationStatus}');

  // Récupérer et logger le FCM token
  final fcmToken = await messaging.getToken();
  log('FCM Token: $fcmToken');
  // TODO: envoyer ce token à votre backend pour cibler cet appareil

  // Écouter les rafraîchissements de token
  messaging.onTokenRefresh.listen((newToken) {
    log('FCM Token rafraîchi: $newToken');
    // TODO: mettre à jour le token sur votre backend
  });

  // Message reçu en premier plan
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('OnMessage (foreground): ${message.data}');
    log('Notification title: ${message.notification?.title}');
    log('Notification body: ${message.notification?.body}');
    showFlutterNotification(message); // Afficher la notification en foreground
  });

  // App ouverte depuis une notification (background → foreground)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    log('onMessageOpenedApp: ${message.data}');
    // TODO: navigation vers l'écran concerné selon message.data
  });

  // App lancée depuis une notification (terminated state)
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    log('App launched from notification: ${initialMessage.data}');
    // TODO: navigation vers l'écran concerné selon initialMessage.data
  }

  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: Obx(
            () => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData().copyWith(
            dropdownMenuTheme: const DropdownMenuThemeData().copyWith(
              menuStyle: MenuStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  return Colors.white;
                }),
              ),
            ),
          ),
          textDirection: Get.find<GlobalRxVariableController>().isRtl.value
              ? TextDirection.rtl
              : TextDirection.ltr,
          locale: language == null ? Get.deviceLocale : Locale(language!),
          translations: LanguageController(),
          fallbackLocale:
          language != null ? Locale(language!) : const Locale('en'),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
        ),
      ),
    ),
  );
}