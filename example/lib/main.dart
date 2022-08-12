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
                    server: "https://demo.amani.ai",
                    token:
                        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyMCwiZXhwIjoxNjYwMjI2NjgzLCJ1c2VybmFtZSI6Im1vYmlsZV90ZWFtQGFtYW5pLmFpIiwiY3VzdG9tZXJfaWQiOjkwOTEsImNvbXBhbnlfaWQiOjJ9.JUciEE0whxZhRC30uU5vnex4eyqcWgaMFDxPM4QyJT8",
                    id: "1111111111");
                print(result.rules?.first.runtimeType);
                setState(() {});
              }),
        ),
      ),
    );
  }
}
