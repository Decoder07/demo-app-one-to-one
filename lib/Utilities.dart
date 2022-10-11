import 'package:permission_handler/permission_handler.dart';

class Utilities {
  static void getPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }

  static const fcmToken =
      "Enter the device id here"; //Enter the device id or firebase token here

  static const meetingUrl =
      "https://decoder.app.100ms.live/preview/xno-jwn-phi"; //Set the meetingUrl to be joined here

  static const user = "Demo"; //The user name to be used in the application

}
