import 'package:decode_100ms/Utilities.dart';
import 'package:decode_100ms/color.dart';
import 'package:decode_100ms/firebase_messaging.dart';
import 'package:decode_100ms/hms_notifier.dart';
import 'package:decode_100ms/video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CallerScreen extends StatelessWidget {
  const CallerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hmsdefaultColor,
        title: const Text(
          "100ms_Call",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 20,
          itemBuilder: (context, index) => tile(context, "User ${index + 1}"),
        ),
      ),
    );
  }

  Widget tile(BuildContext context, String name) {
    HMSNotifier _hmsNotifier = context.read<HMSNotifier>();
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5),
      child: ListTile(
          dense: false,
          horizontalTitleGap: 5,
          enabled: false,
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.account_circle_sharp,
            color: themeDefaultColor,
            size: 28,
          ),
          title: Text(
            name,
            semanticsLabel: "fl_mirror_camera_enable",
            style: GoogleFonts.inter(
                fontSize: 14,
                color: themeDefaultColor,
                letterSpacing: 0.25,
                fontWeight: FontWeight.w600),
          ),
          trailing: GestureDetector(
            // This calls the preview and join for the caller
            onTap: (() async => {
                  //call method sends call notification to the person whom we are calling
                  await MessagingService.call(),

                  //Enter the user and the room link to be joined
                  await _hmsNotifier.startPreview(
                      Utilities.user, Utilities.meetingUrl),

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ListenableProvider.value(
                            value: context.read<HMSNotifier>(),
                            child: VideoCallScreen(),
                          )))
                }),
            child: CircleAvatar(
              backgroundColor: hmsdefaultColor,
              child: const Icon(
                Icons.phone,
                color: Colors.white,
              ),
            ),
          )),
    );
  }
}
