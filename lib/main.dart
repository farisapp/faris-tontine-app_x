import 'dart:async';
import 'package:faris/firebase_options.dart';
import 'package:faris/services/background_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:faris/common/app_constant.dart';
import 'package:faris/common/notification_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:faris/controller/splash_controller.dart';
import 'package:workmanager/workmanager.dart';
import 'package:faris/route/routes.dart';
import 'binding/get_di.dart' as di;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:faris/services/foreground_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lancer rapidement l'application avec un écran temporaire
  runApp(MyAppLoading());

  // Initialisation des services en arrière-plan
  await _initServices();

  // Redémarre l'application complète après initialisation
  runApp(
    WithForegroundTask(
      child: MyApp(),
    ),
  );
}

Future<void> _initServices() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Demande de permission avec options précises
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
  );
  print('🟢 Autorisation notifications : ${settings.authorizationStatus}');

  await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await MobileAds.instance.initialize();
  await di.init();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
}

// Écran temporaire de chargement pendant les initialisations
class MyAppLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

// Application principale après initialisation
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'location_foreground_channel',
        channelName: 'Suivi GPS Livreurs',
        channelDescription: 'Notification pour le suivi de la position du livreur',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 120000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    return GetBuilder<SplashController>(builder: (splashController) {
      return GetMaterialApp(
        title: AppConstant.APP_NAME,
        navigatorKey: Get.key,
        initialRoute: RouteHelper.getSplashRoute(),
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 500),
        getPages: RouteHelper.routes,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.white,
        ),
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr'),
          Locale('en'),
        ],
      );
    });
  }
}
