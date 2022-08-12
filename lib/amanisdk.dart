import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:amanisdk/sdkresult.dart';
import 'amanisdk_platform_interface.dart';

class Amanisdk {
  Future<SdkResult> startAmaniSDKWithToken({
    required String server,
    required String token,
    required String id,
    String? birthDate,
    String? expireDate,
    String? documentNo,
    bool? geoLocation,
    String? lang,
    String? email,
    String? phone,
    String? name,
  }) async {
    // Adds the suffix for api endpoints.
    final String serverURL = Platform.isAndroid ? '$server/api/v1/' : server;

    final callResult = await AmanisdkPlatform.instance.startAmaniSDKWithToken(
        serverURL,
        token,
        id,
        birthDate,
        expireDate,
        documentNo,
        geoLocation,
        lang,
        email,
        phone,
        name);

    SdkResult result =
        SdkResult.fromJson(const JsonDecoder().convert(callResult!));
    return result;
  }
}
