import 'package:flutter/material.dart';

import 'package:amanisdk/amanisdk.dart';
import 'package:amanisdk/sdkresult.dart';

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
                    server: "https://tr14.amani.ai",
                    token:
                        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyNywiZXhwIjoxNjcwMzYxMjY1LCJ1c2VybmFtZSI6Im1vYmlsZXRlYW1AYW1hbmkuY29tIiwiY3VzdG9tZXJfaWQiOjgwLCJjb21wYW55X2lkIjoxfQ.RL4R8M1THhQeJB8-C7WGRTTJm33IsPoN2p4MSFO0TuM",
                    id: "t1op0");
                print(result.isTokenExpired);
              }),
        ),
      ),
    );
  }
}
