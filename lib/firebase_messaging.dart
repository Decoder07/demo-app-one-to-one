import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:decode_100ms/utilities.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  static String? _token;
  String? get token => _token;
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> getToken() async {
    _token = await _firebaseMessaging.getToken();
    log("FCM: $_token");
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _token = token;
    });
  }

// This function sends push notification(call) to other user.
// More information about the function can be found here: https://levelup.gitconnected.com/send-push-notifications-from-a-flutter-app-to-devices-with-firebase-9c84ce58fe30
  static Future<void> call() async {
    await getToken();
    var func = FirebaseFunctions.instance.httpsCallable("notifySubscribers");
    var res = await func.call(<String, dynamic>{
      "targetDevices": [Utilities.fcmToken], //Enter the device fcmToken here
      "messageTitle": "Incoming Call",
      "messageBody": "Someone is calling you..."
    });
    log("message was ${res.data as bool ? "sent!" : "not sent!"}");
  }
}
