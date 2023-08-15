import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_flutter/main.dart';
import 'package:firebase_messaging_flutter/notification_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:typed_data';
import 'package:http/http.dart' as http;

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // to show notification when app is in foreground (using flutter_local_notifications)
  final _androidChannel = const AndroidNotificationChannel(
      "high_importance_channel", "High Importance Notifications",
      description: "This channel is used for important notifications",
      importance: Importance.defaultImportance);
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // to open target screen when click on notification
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    navigatorKey.currentState?.pushNamed(
      NotificationScreen.route,
      arguments: message,
    );
  }

  Future initLocalNotifications() async {
    const iOS = IOSInitializationSettings();  // flutter_local_notifications: ^9.8.0+1
    // const iOS = DarwinInitializationSettings(); // flutter_local_notifications: ^13.0.0
    const android = AndroidInitializationSettings("@drawable/ic_launcher");
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(settings,

     // flutter_local_notifications: ^9.8.0+1   // click notif in foreground work well
    onSelectNotification: (payload){
      final message = RemoteMessage.fromMap(jsonDecode(payload as String));
      handleMessage(message);
    }


      // flutter_local_notifications: ^13.0.0   // click dosent work it dosent open notifiDetailScreen when app is in foreground
    //     onDidReceiveNotificationResponse: (payload) {
    //   final message = RemoteMessage.fromMap(jsonDecode(payload as String));
    //   handleMessage(message);
    // }

    );


    // for android (for ios you should find to do that)
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await platform?.createNotificationChannel(_androidChannel);
  }

  //essential for ios foreground notification
  Future initPushNotification() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp
        .listen(handleMessage); // to open application when app is in background
    FirebaseMessaging.onBackgroundMessage(
        handleBackgroundMessage); // background handler

    FirebaseMessaging.onMessage.listen((message) async {
      // used async for await in bicPictureNotification
      //foreground handler
      final notification = message.notification;
      if (notification == null) return;

      // message.data["image"] = "https://ik.imagekit.io/ikmedia/backlit.jpg";
      if (message.data['image'] != null) {
        // show big picture

        // final imageUrl = message.data['image']; // Assuming the image URL is provided in data
        final imageUrl =
            "https://ik.imagekit.io/ikmedia/backlit.jpg"; // Assuming the image URL is provided in data
        final ByteArrayAndroidBitmap bigPicture =
            ByteArrayAndroidBitmap(await _getByteArrayFromUrl(imageUrl));
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: "@drawable/ic_launcher",
              styleInformation: BigPictureStyleInformation(
                bigPicture,
                contentTitle: notification.title ?? '',
                summaryText: notification.body ?? '',
              ),
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );
      } else {
        //simple notification
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
                _androidChannel.id, _androidChannel.name,
                channelDescription: _androidChannel.description,
                icon: "@drawable/ic_launcher"),
          ),
          payload: jsonEncode(message.toMap()),
        );
      }

      // initLocalNotifications();

      //this snippet of code navigate toNotificationScreen right after receive notif (no need to click on notif)
      // Handle navigation to NotificationScreen when notification is received in foreground
      // navigatorKey.currentState?.pushNamed(
      //   NotificationScreen.route,
      //   arguments: message,
      // );
    });
  }

  // initializing notification
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print("MyAppToken: $fCMToken");
    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    initPushNotification();
    initLocalNotifications();
  }

  static Future<Uint8List> _getByteArrayFromUrl(String? url) async {
    final http.Response response = await http.get(Uri.parse(url!));
    return response.bodyBytes;
  }
}

// data show in notification
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}
