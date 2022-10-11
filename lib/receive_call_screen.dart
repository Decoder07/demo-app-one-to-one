import 'package:decode_100ms/Utilities.dart';
import 'package:decode_100ms/color.dart';
import 'package:decode_100ms/hms_notifier.dart';
import 'package:decode_100ms/video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReceiveCall extends StatefulWidget {
  final String user;

  const ReceiveCall({Key? key, this.user = "Demo"}) : super(key: key);

  @override
  State<ReceiveCall> createState() => _ReceiveCallState();
}

class _ReceiveCallState extends State<ReceiveCall> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: hmsdefaultColor,
        title: const Text(
          "100ms_Call",
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 40,
              backgroundColor: hmsdefaultColor,
              child: Text(
                widget.user.substring(0, 1),
                style: TextStyle(
                    color: themeDefaultColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ListenableProvider.value(
              value: context.read<HMSNotifier>(),
              child: context.watch<HMSNotifier>().isPreviewSuccessful
                  ? Column(
                      children: [
                        context.watch<HMSNotifier>().remotePeer != null
                            ? Text(
                                "${context.read<HMSNotifier>().remotePeer?.name} is calling...")
                            : Container(),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              shadowColor:
                                  MaterialStateProperty.all(surfaceColor),
                              backgroundColor:
                                  MaterialStateProperty.all(hmsdefaultColor),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ))),
                          onPressed: () async {
                            Utilities.getPermissions();
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => ListenableProvider.value(
                                        value: context.read<HMSNotifier>(),
                                        child: const VideoCallScreen())));
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Accept",
                                    style: GoogleFonts.inter(
                                        color: enabledTextColor,
                                        height: 1.5,
                                        fontSize: 16,
                                        letterSpacing: 0.5,
                                        fontWeight: FontWeight.w600))
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      "Connecting...",
                      style: TextStyle(
                          color: themeDefaultColor,
                          fontWeight: FontWeight.bold),
                    ),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
