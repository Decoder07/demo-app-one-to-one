# hms_call

Flutter application for one-to-one calls using 100ms SDK

## How to make a calling application using 100ms

This readme guides you about how you can build a one-to-one calling application using 100ms flutter SDK.

Checkout the video [here](https://www.youtube.com/shorts/5eAnJTwgVVY).

This application has three important parts :

- Call remote peer
- Handle incoming call
- One-to-One video call

Let's get into each one of them : 

### Call remote peer

In this application, we are using firebase cloud functions to call remote peers. For the sake of simplicity, we have hard-coded the `device_id`` to which the notifications need to be sent but this can be configured as per the use-case.


More info about how to set up the firebase cloud functions can be found [here](https://levelup.gitconnected.com/send-push-notifications-from-a-flutter-app-to-devices-with-firebase-9c84ce58fe30)

#### What happens as the call button is pressed 
1. We have the `call` function in our `MessagingService` class by which we are sending the call notifications
as soon as the call button is pressed.

<p>
<img src="https://github.com/Decoder07/demo-app-one-to-one/blob/Fast-preview-join/assets/caller_flow.png" title="caller-flow" float=center height=150>
</p>

2. Then, we call the preview method `startPreview` from our `HMSNotifier` class which internally calls the HMSSDK `preview` method.

```dart
await _hmsNotifier.startPreview(Utilities.user,Utilities.meetingUrl),
```

3. Then we navigate to`VideoCallScreen` whose init method calls the `joinMeeting` which in turn calls the HMSSDK `join` method 
and that's it. 

```dart
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
```

We have successfully joined the room and now we just have to wait for another peer to pick up the call.

### Handle incoming call

As the remote peer calls, we will receive a push notification at our end notifying us that someone is trying to call.
To receive notifications we have used `FirebaseMessaging`.
For the firebase messaging setup please follow the docs [here](https://blog.logrocket.com/add-flutter-push-notifications-firebase-cloud-messaging/)

In this app the notification we receive has the following fields:

- `Message title` -> Which gets displayed as notification title
- `Message description` -> A small message which appears with a title on the notification dialog
- `Meeting Link` -> Will be used in the app to join the room
- `Caller` -> Will be used in the app to get details about the caller

The notification handling needs to be done for the three states that the app can be in when the notification is received/clicked.

- Terminated
If the application is in terminated state and the notification is received `checkForInitialMessage` method takes care of it as soon as the notification is clicked.

```dart
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    //[initialMessage] - contains the message which we have received from notification
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      receiveCall(initialMessage);
    }
  } 
```

- Background 

If the application is running but is in the background then `onBackgroundMessage` gets executed and as the notification is tapped `onMessageOpenedApp` gets executed as:

```dart
FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("Called by ${message.data["caller"]} and link is ${message.data["link"]}");
        receiveCall(message);
      });
```

- Foreground
When the application is running in the foreground we get the update on the `onMessage` method and then we show the alert dialog inside the app as :

```dart
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
                    onPressed: () => {
                    Navigator.pop(context),
                    receiveCall(message)
                    },
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
```

We have written the `receiveCall` method for receiving calls which in turn calls the HMSSDK's `preview` method and once we receive `onPreview` we show the option to join the room as :

<p align="center">
<img src="https://github.com/Decoder07/demo-app-one-to-one/blob/Fast-preview-join/assets/receive_call.png" title="receive-call" float=center height=400>
</p>

### One-to-One video call

Once the user joins the room we render `VideoCallScreen` which subscribes to `HMSNotifier` updates.
We have two video views in the `VideoCallScreen`:

- Floating tile for local peer
- Full-screen view for the remote peer

We have `localPeerVideoTrack` for local peer track and `remotePeerVideoTrack` for remote peer video track.
Similarly, we have `localPeer` for the local peer object and `remotePeer` for the remote peer.

#### Read more about the implementation [100ms-docs](https://www.100ms.live/docs/flutter/v2/foundation/basics)

#### For other use, cases check out: [100ms-flutter-repo](https://github.com/100mslive/100ms-flutter)

#### Queries and Questions: [Discord](https://discord.gg/XCtqR5Xj)
