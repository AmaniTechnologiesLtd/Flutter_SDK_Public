import 'package:flutter/material.dart';

import 'package:amani_flutter_sdk/amanisdk.dart';
import 'package:amani_flutter_sdk/sdkresult.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _amanisdkPlugin = Amanisdk();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Amani SDK Plugin'),
        ),
        body: Center(
          child: TextButton(
              child: const Text("Start Button"),
              onPressed: () async {
                var result = await _amanisdkPlugin.startAmaniSDKWithToken(
                    server: "https://dev.amani.ai",
                    token:
                        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjg5NTg4ODc4LCJpYXQiOjE2ODg5ODQwNzgsImp0aSI6ImYxY2Y5MzY2NzVhZDQxNGFhZmFhMDljNjQ5MDk4NGRjIiwidXNlcl9pZCI6IjA5YmZhOWM2LWZhYmMtNDYwNy1iMDM3LTc5NWQ1N2UzNGNjYyIsImNvbXBhbnlfaWQiOiI0ZTNmZGY2Mi01N2RjLTQzNTgtOTdkMi1mOGI1Njg4ZGNmYjciLCJwcm9maWxlX2lkIjoiMzZhNjc5NGMtMjczNy00YzUwLThmY2MtNzlhNjUwYmY0ZGM3IiwiYXBpX3VzZXIiOmZhbHNlfQ.AdvRBqqa9CEGEUc--KCZbfmGs-qIbtoRfaQqAho_2Ic",
                    id: "456456456");
                print(result.isTokenExpired);
                // var result = await _amanisdkPlugin.startAmaniSDKWithCredentials(
                //     server: "https://dev.amani.ai",
                //     loginEmail: "deniz@amani.ai",
                //     loginPassword: "uecJQ\*B47\+\$QVW",
                //     id: "454545");
                // print(result.isTokenExpired);
              }),
        ),
      ),
    );
  }
}
