import 'package:amani_flutter_sdk/amaniAndroidConfigure.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:amani_flutter_sdk/amanisdk.dart';
import 'package:amani_flutter_sdk/sdkresult.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:path_provider/path_provider.dart';
import 'dart:convert';
// import 'package:path/path.dart';

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
                // String filePath = await getAssetFilePath('lib/assets/certificate/bclient.amani.ai.cer');
                //   print('Dosya Yolu: $filePath');

                // _amanisdkPlugin.setSSLPinning(filePath);
                if(Platform.isAndroid) {
                  await _amanisdkPlugin.configure(
                  server: "",
                  enabledFeatures: const [
                    AmaniFeature.idCapture,
                    AmaniFeature.idHologramDetection,
                    AmaniFeature.nfcScan,
                    AmaniFeature.selfieAuto,
                    AmaniFeature.selfiePoseEstimation,
                  ],
                );

                final result = await _amanisdkPlugin.startAmaniSDKConfigurable(
                  token: "",
                  id: "",
                  
                  // geoLocation: true,
                  // lang: "tr",
                );

                print(result.isTokenExpired);

                } else {
                    var result = await _amanisdkPlugin.startAmaniSDKWithToken(
                    server: "",
                    token: "",
                    id: "");
                   print(result.isTokenExpired);
                }
              
              }),
        ),
      ),
    );
  }

  Future<String> loadAsset() async {
    try {
      // Asset dosyasını yükle
      String certificateBase64 = "";
      ByteData data =
          await rootBundle.load('lib/assets/certificate/bclient.amani.ai.cer');

      // ByteData → Uint8List
      Uint8List uint8List = data.buffer.asUint8List();

      // Uint8List → Base64 String
      String base64String = base64Encode(uint8List);
      certificateBase64 = base64String;

      return certificateBase64;
    } catch (e) {
      print('Hata oluştu: $e');
      return 'Hata: $e';
    }
  }

  Future<String> getAssetFilePath(String assetPath) async {
    try {
      // Asset içeriğini oku
      ByteData data = await rootBundle.load(assetPath);

      // Geçici dosya yolu al
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/${assetPath.split('/').last}';

      // ByteData → Uint8List → Dosyaya yaz
      File tempFile = File(tempPath);
      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);

      print('Geçici dosya yolu: $tempPath');
      return tempPath; // 🔥 Artık asset'in dosya yolu var
    } catch (e) {
      print('Hata oluştu: $e');
      return '';
    }
  }
}
