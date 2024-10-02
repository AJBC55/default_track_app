import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'map/view.dart';
import 'events/view.dart';
import 'loading_screen.dart';
import 'timing/timing.dart';
import 'timing/timing_provider.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> sendTokenToBackend(String token) async {
  final url =
      'https://css-container-ztob2eeuta-uc.a.run.app/consumer/notification-token';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'token': token,
        'trackId': 1,
      }),
    );

    if (response.statusCode == 201) {
      print('Token successfully sent to backend');
    } else {
      print(
          'Failed to send token to backend. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending token to backend: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );*/

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
   runApp(
    ChangeNotifierProvider(
      create: (context) => TimingSessionProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoadingScreen(),
        '/home': (context) => HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FirebaseMessaging _messaging;

  @override
  void initState() {
    super.initState();
    _messaging = FirebaseMessaging.instance;
    _messaging
        .requestPermission(
      alert: true,
      badge: true,
      sound: true,
    )
        .then((NotificationSettings settings) {
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _messaging.getToken().then((String? token) {
          if (token != null) {
            print("FCM Token: $token");
            sendTokenToBackend(token);
          }
        });
      } else {
        print('User declined or has not granted permission');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: TabBarView(
          children: [
            EventsScreen(),
            MapView(),
            ChangeNotifierProvider(
            create: (context) => TimingSessionProvider(), 
            child: TimingScreen(),
          ),
          ],
        ),
        bottomNavigationBar: const Material(
          child: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Events'),
              Tab(icon: Icon(Icons.map_outlined), text: 'Map'),
              Tab(icon: Icon(Icons.timer), text: 'Timing'),
            ],
          ),
        ),
      ),
    );
  }
}
