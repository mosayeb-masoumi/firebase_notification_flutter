

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const route = "/notification_screen";
  @override
  Widget build(BuildContext context) {

    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage ;
    var a = message;
    return Scaffold(
      appBar: AppBar(title: Text("Push Notifications"),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text("${message.notification?.title}"),
             Text("${message.notification?.body}"),
             Text("${message.data}"),
          ],
        )
      ),
    );
  }
}



