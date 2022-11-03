import 'package:flutter/material.dart';

import 'package:amanisdk_android/amanisdk.dart';
import 'package:amanisdk_android/sdkresult.dart';

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
                    server: "https://server.example",
                    token: "customer_token",
                    id: "customer_id_number");
                setState(() {});
              }),
        ),
      ),
    );
  }
}
