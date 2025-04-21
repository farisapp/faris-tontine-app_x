import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:faris/controller/last_tontine_controller.dart';
import 'package:faris/controller/tontine_controller.dart';
import 'package:faris/controller/tontine_details_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:faris/common/app_constant.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static Future<void> initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;


    if (Platform.isIOS) {
     String? apnsToken = await messaging.getAPNSToken();
    print("apns token : $apnsToken");
    } else {
      // Android specific code
    String? token = await messaging.getToken();
        print("Token FCM : $token");

    }
    

    var androidInitialize = new AndroidInitializationSettings("appicon");
    var iOSInitialize = new DarwinInitializationSettings();
    var initiazationsSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSInitialize);

    NotificationHelper.requestNotificationPermission();

    flutterLocalNotificationsPlugin.initialize(initiazationsSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
      try {
        if (notificationResponse.payload != null &&
            notificationResponse.payload!.isNotEmpty) {
          print(
              "AFFICHAGE DE LA FENETE ICI => ${notificationResponse.payload}");
          /*var data = payload.split("_");
          if(data[1] != null){
            if(data[1] == "activite"){

            }else if(data[1] == "publication"){
              //Get.toNamed(AppRoutes.getNewsRoute(int.parse(data[0])));
            }
          }*/
        } else {
          //Get.toNamed(RouteHelper.);
        }
      } catch (e) {}
      return;
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("MESSAGE FOREGROUND => => ${message.data.toString()}");
      NotificationHelper.showNotification(
          message, flutterLocalNotificationsPlugin);
      if (message.data['type'] == "tontine_status") {
        Get.find<LastTontineController>().getLastTontine(true);
        Get.find<TontineController>().getPendingTontines(true);
        Get.find<TontineDetailsController>()
            .getTontineDetails(int.parse(message.data['tontine_id']), true);
      } else if (message.data['type'] == "request_status") {
        Get.find<TontineDetailsController>()
            .getTontineRequetes(int.parse(message.data['tontine_id']), true);
      }
      /*if(message.notification != null){
        print('Message also contained a notification: ${message.notification}');
      }*/
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageApp ${message.data}');
    });
  }

  static void requestNotificationPermission() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
            alert: true,
            announcement: true,
            badge: true,
            carPlay: true,
            criticalAlert: true,
            provisional: true,
            sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("L'utilisateur a authorise les notifs");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("L'utilisateur a authorise de maniere provisoir les notifs");
    } else {
      AppSettings.openAppSettings();
      print("L'utilisateur a refuse les notifs");
    }
  }

  static Future<void> showNotification(
      RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    if (message.data["image"] != null && message.data['image'].isNotEmpty) {
      try {
        await showBigPictureNotificationHiddenLarge(message, fln);
      } catch (e) {
        print("ERROR => $e");
        await showBigTextNotification(message, fln);
      }
    } else {
      await showBigTextNotification(message, fln);
    }
  }

  static Future<void> showBigTextNotification(
      RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    print("MESSAGE BACKGROUND => ${message.toString()}");
    String _title = message.data['title'] ?? "";
    String _body = message.data['body'] ?? "";
    String _id = message.data['tontine_id'] ?? "";
    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
      _body,
      contentTitle: _title,
      summaryText: _body,
      htmlFormatContentTitle: true,
      htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlateformChannelSpecifics =
        AndroidNotificationDetails(
            "${AppConstant.TOPIC}", "Notification General",
            playSound: true,
            importance: Importance.max,
            priority: Priority.high,
            icon: "appicon",
            largeIcon: DrawableResourceAndroidBitmap('appicon'),
            styleInformation: bigTextStyleInformation);
    final NotificationDetails plateFormChannelSpecifics =
        NotificationDetails(android: androidPlateformChannelSpecifics);
    fln.show(0, _title, _body, plateFormChannelSpecifics, payload: _id);
  }

  static Future<void> showBigPictureNotificationHiddenLarge(
      RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    print("MESSAGE BACKGROUND IMAGE => ${message.toString()}");
    String _title = message.data['title'] ?? "";
    String _body = message.data['body'] ?? "";
    String _id = message.data['tontine_id'] ?? "";
    String _image = message.data['image'].startsWith('http')
        ? message.data['image']
        : "${AppConstant.BASE_IMAGE_URL}/notification/${message.data['image']}";
    final String largeIconPath =
        await _downloadAndSaveFile(_image, 'largeIcon');
    final String bigPicturePath =
        await _downloadAndSaveFile(_image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
            hideExpandedLargeIcon: true,
            contentTitle: _title,
            htmlFormatContentTitle: true,
            summaryText: _body,
            htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidPlateformChannelSpecifics =
        AndroidNotificationDetails(
            "${AppConstant.TOPIC}", "Notification General",
            largeIcon: FilePathAndroidBitmap(largeIconPath),
            playSound: true,
            importance: Importance.high,
            priority: Priority.high,
            icon: "appicon",
            styleInformation: bigPictureStyleInformation);
    final NotificationDetails plateFormChannelSpecifics =
        NotificationDetails(android: androidPlateformChannelSpecifics);
    fln.show(0, _title, _body, plateFormChannelSpecifics, payload: _id);
  }

  static Future<String> _downloadAndSaveFile(
      String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}

@pragma('vm:entry-point')
Future<dynamic> backgroundHandler(RemoteMessage message) async {
  print("MESSAGE BACKGROUND => ${message.data.toString()}");
  var androidInitialize = new AndroidInitializationSettings("appicon");
  var iOSInitialize = new DarwinInitializationSettings();
  var initiazationsSettings = new InitializationSettings(
      android: androidInitialize, iOS: iOSInitialize);
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  flutterLocalNotificationsPlugin.initialize(initiazationsSettings);
  NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin);
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("A Background message just showed up : ${message.messageId}");
}

void setupNotificationChannel() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // ID unique pour le canal
    'Notifications importantes', // Nom du canal
    description:
        'Ce canal est utilisé pour des notifications importantes.', // Description
    importance: Importance.max,
  );
  print('chanel Id => ${channel.id}');

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}
