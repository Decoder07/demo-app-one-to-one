import 'dart:developer';

import 'package:decode_100ms/color.dart';
import 'package:decode_100ms/hms_notifier.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:provider/provider.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  Offset position = const Offset(5, 5);

  @override
  void initState() {
    super.initState();
    initMeeting();
  }

  void initMeeting() async {
    bool ans = await context.read<HMSNotifier>().joinMeeting();
    if (!ans) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    HMSPeer? localPeer = context
        .select<HMSNotifier, HMSPeer?>((hmsNotifier) => hmsNotifier.localPeer);
    HMSPeer? remotePeer = context
        .select<HMSNotifier, HMSPeer?>((hmsNotifier) => hmsNotifier.remotePeer);
    HMSVideoTrack? localTrack = context.select<HMSNotifier, HMSVideoTrack?>(
        (hmsNotifier) => hmsNotifier.localPeerVideoTrack);
    HMSVideoTrack? remoteTrack = context.select<HMSNotifier, HMSVideoTrack?>(
        (hmsNotifier) => hmsNotifier.remotePeerVideoTrack);
    log("onPreview Remote track ${remoteTrack == null} and isMute ${remoteTrack?.isMute ?? "NULL"}");
    return WillPopScope(
      onWillPop: () async {
        context.read<HMSNotifier>().leaveRoom();
        Navigator.pop(context);
        return true;
      },
      child: SafeArea(
          child: Scaffold(
        body: Stack(children: [
          (remotePeer == null)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: hmsdefaultColor,
                            child: Text(
                              "D",
                              style: TextStyle(
                                  color: themeDefaultColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const Text(
                            "Connecting...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    remoteTrack?.isMute ?? true
                        ? Center(
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withAlpha(60),
                                      blurRadius: 10.0,
                                      spreadRadius: 2.0,
                                    ),
                                  ]),
                            ),
                          )
                        : (remoteTrack != null)
                            ? SizedBox(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: HMSVideoView(
                                    scaleType: ScaleType.SCALE_ASPECT_FILL,
                                    track: remoteTrack,
                                    matchParent: false),
                              )
                            : const Center(child: Text("No Video")),
                    remoteTrack?.isMute ?? true
                        ? Align(
                            alignment: Alignment.center,
                            child: Text(
                              remotePeer.name.substring(0, 1),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w600),
                            ),
                          )
                        : Container(),
                  ],
                ),
          DraggableWidget(
            child: localPeerTile(localTrack, context),
            topMargin: 30,
            bottomMargin: 100,
            horizontalSpace: 10,
          ),
          Positioned(
            top: 10,
            left: 10,
            child: GestureDetector(
              onTap: () {
                context.read<HMSNotifier>().leaveRoom();
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () {
                if (context.read<HMSNotifier>().isLocalVideoOn) {
                  context.read<HMSNotifier>().switchCamera();
                }
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.transparent.withOpacity(0.2),
                child: const Icon(
                  Icons.switch_camera_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () async {
                      context.read<HMSNotifier>().leaveRoom();
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, boxShadow: [
                        BoxShadow(
                          color: Colors.red.withAlpha(60),
                          blurRadius: 3.0,
                          spreadRadius: 5.0,
                        ),
                      ]),
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.call_end, color: Colors.white),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {context.read<HMSNotifier>().switchVideo()},
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.transparent.withOpacity(0.2),
                      child: Icon(
                        context.watch<HMSNotifier>().isLocalVideoOn
                            ? Icons.videocam
                            : Icons.videocam_off_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => {context.read<HMSNotifier>().switchAudio()},
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.transparent.withOpacity(0.2),
                      child: Icon(
                        context.read<HMSNotifier>().isLocalAudioOn
                            ? Icons.mic
                            : Icons.mic_off,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      )),
    );
  }
}

Widget localPeerTile(HMSVideoTrack? localTrack, BuildContext context) {
  return ClipRRect(
    borderRadius: const BorderRadius.all(Radius.circular(10)),
    child: Container(
      height: 150,
      width: 120,
      color: Colors.grey.withOpacity(0.1),
      child: (context.watch<HMSNotifier>().isLocalVideoOn && localTrack != null)
          ? HMSVideoView(
              track: localTrack,
            )
          : Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(4),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.blue,
                      blurRadius: 20.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                ),
                child: Text(
                  context.read<HMSNotifier>().localPeer?.name.substring(0, 1) ??
                      "D",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ),
            ),
    ),
  );
}
