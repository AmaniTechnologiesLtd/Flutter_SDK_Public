import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:amanisdk/sdkresult.dart';
import 'package:flutter/services.dart';
import 'amanisdk_platform_interface.dart';

class Amanisdk {
  Completer<SdkResult>? _completer;

  /// Starts our native android or ios sdk.
  /// [server], [token], and [id] fields are required.
  ///
  /// [birthDate], [expireDate] and [documentNo] fields are grouped optionals so
  /// you must use all of them if you use one of them.
  ///
  /// Any *date* format is in **YYMMDD** format.
  ///
  /// [email], [phone], [name] fields are related to customer profile.
  ///
  ///
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
    String serverURL = Platform.isAndroid ? '$server/api/v1/' : server;

    await AmanisdkPlatform.instance.startAmaniSDKWithToken(
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

    _completer = Completer<SdkResult>();

    AmanisdkPlatform.instance.methodChannel
        .setMethodCallHandler(_handleInverseChannel);
    return _completer!.future;
  }

  Future<void> _handleInverseChannel(MethodCall call) async {
    switch (call.method) {
      case 'onSuccess':
        print("RESULT FROM INVOKEMETHOD");
        final result = SdkResult.fromJson(jsonDecode(call.arguments));
        print(result);
        _completer?.complete(result);
        break;
    }
  }

  // Future<SdkResult> startAmaniSDKWithCredentials({
  //   required String server,
  //   required String loginEmail,
  //   required String loginPassword,
  //   required String id,
  //   String? birthDate,
  //   String? expireDate,
  //   String? documentNo,
  //   bool? geoLocation,
  //   String? lang,
  //   String? email,
  //   String? phone,
  //   String? name,
  // }) async {
  //   // Adds the suffix for api endpoints.
  //   String serverURL = Platform.isAndroid ? '$server/api/v1/' : server;

  //   final callResult = await AmanisdkPlatform.instance
  //       .startAmaniSDKWithCredentials(
  //           serverURL,
  //           loginEmail,
  //           loginPassword,
  //           id,
  //           birthDate,
  //           expireDate,
  //           documentNo,
  //           geoLocation,
  //           lang,
  //           email,
  //           phone,
  //           name);

  //   SdkResult result =
  //       SdkResult.fromJson(const JsonDecoder().convert(callResult!));
  //   return result;
  // }
}
