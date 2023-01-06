import 'package:decode_100ms/hms_services.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class HMSNotifier extends ChangeNotifier implements HMSUpdateListener {
  late HMSSDK hmsSDK;

  HMSNotifier() {
    hmsSDK = HMSSDK();
    hmsSDK.build();
  }

  HMSVideoTrack? localPeerVideoTrack, remotePeerVideoTrack;
  bool isLocalVideoOn = true, isLocalAudioOn = true;
  HMSPeer? localPeer, remotePeer;

  Future<bool> joinMeeting() async {
    List<String?>? token = await HMSServices().getToken(
        user: "test",
        room:
            "https://decoder.app.100ms.live/preview/xno-jwn-phi");
    if (token == null) return false;
    HMSConfig config = HMSConfig(authToken: token[0]!, userName: "test");
    hmsSDK.addUpdateListener(listener: this);
    hmsSDK.join(config: config);
    return true;
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {
    // TODO: implement onAudioDeviceChanged
  }

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {
    // TODO: implement onChangeTrackStateRequest
  }

  @override
  void onHMSError({required HMSException error}) {
    // TODO: implement onHMSError
  }

  @override
  void onJoin({required HMSRoom room}) {
    // TODO: implement onJoin
    room.peers?.forEach((peer) {
      if (peer.isLocal) {
        localPeer = peer;
        if (peer.videoTrack != null) {
          localPeerVideoTrack = peer.videoTrack;
        }
      }
    });
    notifyListeners();
  }

  @override
  void onMessage({required HMSMessage message}) {
    // TODO: implement onMessage
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    // TODO: implement onPeerUpdate
    if (update == HMSPeerUpdate.peerJoined) {
      if (!peer.isLocal) {
        remotePeer = peer;
      }
    } else if (update == HMSPeerUpdate.peerLeft) {
      if (!peer.isLocal) {
        remotePeer = null;
      } else {
        localPeer = null;
      }
    }
    notifyListeners();
  }

  @override
  void onReconnected() {
    // TODO: implement onReconnected
  }

  @override
  void onReconnecting() {
    // TODO: implement onReconnecting
  }

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    localPeer = null;
    // TODO: implement onRemovedFromRoom
  }

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {
    // TODO: implement onRoleChangeRequest
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    // TODO: implement onRoomUpdate
  }

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      if (trackUpdate == HMSTrackUpdate.trackRemoved) {
        if (peer.isLocal) {
          localPeerVideoTrack = null;
        } else {
          remotePeerVideoTrack = null;
        }
        return;
      }
      if (peer.isLocal) {
        localPeerVideoTrack = track as HMSVideoTrack;
      } else {
        remotePeerVideoTrack = track as HMSVideoTrack;
      }
      notifyListeners();
    }
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    // TODO: implement onUpdateSpeakers
  }

  void switchCamera() {
    hmsSDK.switchCamera();
  }

  void leaveRoom() {
    hmsSDK.removeUpdateListener(listener: this);
    hmsSDK.leave();
  }

  void switchVideo() {
    hmsSDK.switchVideo(isOn: isLocalVideoOn);
    isLocalVideoOn = !isLocalVideoOn;
    notifyListeners();
  }

  void switchAudio() {
    hmsSDK.switchAudio(isOn: isLocalAudioOn);
    isLocalAudioOn = !isLocalAudioOn;
    notifyListeners();
  }
}
