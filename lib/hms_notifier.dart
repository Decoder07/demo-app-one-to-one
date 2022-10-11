import 'dart:developer';

import 'package:decode_100ms/hms_services.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class HMSNotifier extends ChangeNotifier
    implements HMSUpdateListener, HMSPreviewListener, HMSActionResultListener {
  late HMSSDK hmsSDK;

  HMSNotifier() {
    hmsSDK = HMSSDK();
    hmsSDK.build();
  }

  HMSVideoTrack? localPeerVideoTrack, remotePeerVideoTrack;
  bool isLocalVideoOn = true, isLocalAudioOn = true;
  HMSPeer? localPeer, remotePeer;
  List<String?>? token;
  late HMSConfig config;
  bool isPreviewSuccessful = false;
  bool isJoinSuccessful = false;

  Future<void> getToken(String user, String meetingUrl) async {
    token = await HMSServices().getToken(user: user, room: meetingUrl);
    config = HMSConfig(authToken: token![0]!, userName: user);
  }

  Future<bool> joinMeeting() async {
    log("onPreview called join meeting");
    isJoinSuccessful = true;
    hmsSDK.removePreviewListener(listener: this);
    if (token == null) return false;
    hmsSDK.addUpdateListener(listener: this);
    hmsSDK.join(config: config);
    return true;
  }

  Future<bool> startPreview(String user, String meetingUrl) async {
    await getToken(user, meetingUrl);
    if (token == null) return false;
    if (token![0] == null) return false;
    hmsSDK.addPreviewListener(listener: this);
    hmsSDK.preview(config: config);
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

  void cleanStore() {
    localPeer = null;
    remotePeer = null;
    localPeerVideoTrack = null;
    remotePeerVideoTrack = null;
  }

  void leaveRoom() {
    hmsSDK.removeUpdateListener(listener: this);
    isPreviewSuccessful = false;
    cleanStore();
    notifyListeners();
    hmsSDK.leave(hmsActionResultListener: this);
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

  @override
  void onPreview({required HMSRoom room, required List<HMSTrack> localTracks}) {
    log("onPreview-> room: ${room.toString()}");
    for (HMSPeer each in room.peers!) {
      if (each.isLocal) {
        localPeer = each;
        break;
      }
    }
    for (var track in localTracks) {
      if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
        // isVideoOn = !(track.isMute);
        localPeerVideoTrack = track as HMSVideoTrack;
      }
      if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
        // isAudioOn = !(track.isMute);
      }
    }
    // notifyListeners();
    isPreviewSuccessful = true;
    notifyListeners();
  }

  @override
  void onException(
      {HMSActionResultListenerMethod? methodType,
      Map<String, dynamic>? arguments,
      required HMSException hmsException}) {
    // TODO: implement onException
  }

  @override
  void onSuccess(
      {HMSActionResultListenerMethod? methodType,
      Map<String, dynamic>? arguments}) {
    // TODO: implement onSuccess
    switch (methodType) {
      case HMSActionResultListenerMethod.leave:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeTrackState:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeMetadata:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.endRoom:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.removePeer:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.acceptChangeRole:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeRole:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeTrackStateForRole:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.startRtmpOrRecording:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.stopRtmpAndRecording:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.changeName:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.sendBroadcastMessage:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.sendGroupMessage:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.sendDirectMessage:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.hlsStreamingStarted:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.hlsStreamingStopped:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.startScreenShare:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.stopScreenShare:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.startAudioShare:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.stopAudioShare:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.setTrackSettings:
        // TODO: Handle this case.
        break;
      case HMSActionResultListenerMethod.unknown:
        // TODO: Handle this case.
        break;
      default:
        break;
    }
  }
}
