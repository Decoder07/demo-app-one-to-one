import 'package:decode_100ms/hms_notifier.dart';
import 'package:decode_100ms/video_call_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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
      home: const MyHomePage(title: 'Decode 100ms'),
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
  late HMSNotifier dataStore;

  void getPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
  }

  void setDataStore() {
    dataStore = HMSNotifier();
  }

  @override
  Widget build(BuildContext context) {
    Color hmsdefaultColor = const Color.fromRGBO(36, 113, 237, 1);
    Color surfaceColor = const Color.fromRGBO(29, 34, 41, 1);
    Color enabledTextColor = const Color.fromRGBO(255, 255, 255, 0.98);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to 100ms',
            ),
            const SizedBox(
              height: 50,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  shadowColor: MaterialStateProperty.all(surfaceColor),
                  backgroundColor: MaterialStateProperty.all(hmsdefaultColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ))),
              onPressed: () async {
                getPermissions();
                setDataStore();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ListenableProvider.value(
                        value: dataStore, child: VideoCallScreen())));
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Join now",
                        style: GoogleFonts.inter(
                            color: enabledTextColor,
                            height: 1.5,
                            fontSize: 16,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
