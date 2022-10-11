// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:decode_100ms/caller_screen.dart';
import 'package:decode_100ms/color.dart';
import 'package:decode_100ms/hms_notifier.dart';
import 'package:decode_100ms/receive_call_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Background Message is -> ${message.data.toString()}");
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Decode 100ms',
      theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Color.fromARGB(255, 13, 107, 184),
          backgroundColor: Colors.black,
          scaffoldBackgroundColor: Colors.black),
      //HMSNotifer class is the central data store of the application
      home: ListenableProvider.value(
          value: HMSNotifier(), child: const MyHomePage(title: 'Decode 100ms')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final FirebaseMessaging _messaging;

  void receiveCall(RemoteMessage message) {
    String meetingUrl = message.data["link"];
    String user = message.data["caller"];
    context.read<HMSNotifier>().startPreview(user, meetingUrl);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ListenableProvider.value(
              value: context.read<HMSNotifier>(),
              child: ReceiveCall(
                user: user,
              ),
            )));
  }

  // This method takes care of notifications when the app is terminated
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      log("Called by ${initialMessage.data["caller"]} and link is ${initialMessage.data["link"]}");
      receiveCall(initialMessage);
    }
  }

  //This method takes care of firebase push notifications
  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    // This method is called when the app is running in background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    //If the user has allowed notification
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //When the notification is opened by the user
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("Called by ${message.data["caller"]} and link is ${message.data["link"]}");
        receiveCall(message);
      });

      //When app is running and is in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        String user = message.data["caller"];
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  actionsPadding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  insetPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  contentPadding:
                      EdgeInsets.only(top: 20, bottom: 15, left: 24, right: 24),
                  title: Text("$user is calling..."),
                  actions: [
                    ElevatedButton(
                        style: ButtonStyle(
                            shadowColor:
                                MaterialStateProperty.all(themeSurfaceColor),
                            backgroundColor: MaterialStateProperty.all(
                                themeBottomSheetColor),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1,
                                  color: Color.fromRGBO(107, 125, 153, 1)),
                              borderRadius: BorderRadius.circular(8.0),
                            ))),
                        onPressed: () => Navigator.pop(context, false),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 10),
                          child: Text('Decline',
                              style: GoogleFonts.inter(
                                  color: themeDefaultColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.50)),
                        )),
                    ElevatedButton(
                      style: ButtonStyle(
                          shadowColor:
                              MaterialStateProperty.all(themeSurfaceColor),
                          backgroundColor:
                              MaterialStateProperty.all(hmsdefaultColor),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: hmsdefaultColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ))),
                      onPressed: () =>
                          {Navigator.pop(context), receiveCall(message)},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 10),
                        child: Text(
                          'Accept',
                          style: GoogleFonts.inter(
                              color: themeDefaultColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.50),
                        ),
                      ),
                    ),
                  ],
                ));
      });
    }
  }

  @override
  void initState() {
    checkForInitialMessage();
    super.initState();
    registerNotification();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider.value(
        value: context.read<HMSNotifier>(), child: CallerScreen());
  }
}
