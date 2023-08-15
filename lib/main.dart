import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging_flutter/api/firebase_api.dart';
import 'package:firebase_messaging_flutter/home_page.dart';
import 'package:firebase_messaging_flutter/notification_screen.dart';
import 'package:flutter/material.dart';




// SOURCE: https://www.youtube.com/watch?v=k0zGEbiDJcQ

// to navigate to notification_screen
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      home: const HomePage(),
      routes: {
        NotificationScreen.route: (context) => const NotificationScreen()
      },
    );
  }
}


